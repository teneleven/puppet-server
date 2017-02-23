class server (
  $packages = [],
  $cron     = {},
  $groups   = [],
  $users    = {},

  $exec          = {},
  $exec_defaults = {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
  },

  $acls          = {},
  $default_acls  = [],

  # puppet classes to define - should be either list of classes, or FULL::CLASS as KEY and hash PARAMS as value
  $classes       = {},
  # puppet resources - should be FULL::RESOURCE as KEY and hash { NAME => PARAMS } as value
  $resources     = {},
) {
  if ($packages and is_array($packages)) {
    package { $packages: }
  } elsif ($packages and is_hash($packages)) {
    create_resources('package', $packages)
  }

  if ($cron) {
    service { 'cron':
      ensure => $cron['install'],
      enable => $cron['install']
    }

    if ($cron['jobs']) {
      create_resources('cron', $cron['jobs'])
    }
  }

  if ($groups and is_array($groups)) {
    group { $groups:
      ensure => present
    }
  } elsif ($groups and is_hash($groups)) {
    create_resources('group', $groups)
  }

  if ($users and is_hash($users)) {
    # setup relationships from Groups -> Users
    if (!empty($groups)) {
      $groups.each |$group_key,$group_val| {
        $users.each |$user_key,$user_val| {
          if (is_hash($group_val)) {
            $group_name = $group_key
          } else {
            $group_name = $group_val
          }

          if (is_hash($user_val)) {
            $user_name = $group_key
          } else {
            $user_name = $group_val
          }

          Group[$group_name] -> User[$user_name]
        }
      }
    }

    create_resources('user', $users)
  }

  if ($exec and is_array($exec)) {
    $exec.each |$key, $exe| {
      # setup relationship between previous exec
      if (is_integer($key) and $key - 1 >= 0) {
        $prev_exec = $exec[$key - 1]
        Exec["server_exec_${prev_exec}"] -> Exec["server_exec_${exe}"]
      }

      # ensure packages installed before exec
      if (!empty($packages)) {
        $packages.each |$package_key,$package_val| {
          if (is_hash($package_val)) {
            Package[$package_key] -> Exec["server_exec_${exe}"]
          } else {
            Package[$package_val] -> Exec["server_exec_${exe}"]
          }
        }
      }

      create_resources('exec', { "server_exec_${exe}" => merge(
        $exec_defaults,
        { command => $exe }
      ) })
    }
  } elsif ($exec and is_hash($exec)) {
    create_resources('exec', $exec)
  }

  $acls.each |$file, $permissions| {
    create_resources('::fooacl::conf', {"server_acl_${file}" => {
      target      => $file,
      permissions => concat($default_acls, $permissions)
    }})
  }

  if ($classes and is_array($classes)) {
    $classes.each |$class| {
      contain $class
    }
  } elsif ($classes and is_hash($classes)) {
    create_resources('class', $classes)
    $classes.each |$className,$params| {
      contain $className
    }
  }

  if ($resources and is_hash($resources)) {
    $resources.each |$resource, $params| {
      create_resources($resource, $params)
    }
  }
}
