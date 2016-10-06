class server (
  $packages = [],
  $cron     = {},
  $groups   = [],
  $users    = {},

  $exec          = {},
  $exec_defaults = {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
  },

  $acls         = {},
  $default_acls = []
) {
  if ($packages) {
    package { $packages: }
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

  if ($groups) {
    group { $groups: }
  }

  if ($users) {
    create_resources('user', $users)
  }

  $exec.each |$exe| {
    create_resources('exec', { "server_exec_${exe}" => merge(
      $exec_defaults,
      { command => $exe }
    ) })

    /* TODO ??? */
    /* if (!empty($packages)) { */
    /*   Class['::teneleven::apt'] -> Exec["server_exec_${exe}"] */
    /* } */
  }

  $acls.each |$file, $permissions| {
    create_resources('::fooacl::conf', {"server_acl_${file}" => {
      target      => $file,
      permissions => concat($default_acls, $permissions)
    }})
  }
}
