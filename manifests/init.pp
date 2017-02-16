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
    group { $groups: }
  } elsif ($groups and is_hash($groups)) {
    create_resources('group', $groups)
  }

  if ($users and is_hash($users)) {
    create_resources('user', $users)
  }

  # TODO setup relationship(s) between exec and $packages
  if ($exec and is_array($exec)) {
    $exec.each |$exe| {
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
      include $class
    }
  } elsif ($classes and is_hash($classes)) {
    create_resources('class', $classes)
  }

  if ($resources and is_hash($resources)) {
    $resources.each |$resource, $params| {
      create_resources($resource, $params)
    }
  }
}
