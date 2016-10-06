class server (
  $packages = [],
  $cron     = {},
  $groups   = [],
  $users    = {},
) {
  if ($packages) {
    ::package { $packages: }
  }

  if ($cron) {
    ::service { 'cron':
      ensure => $cron['install'],
      enable => $cron['install']
    }

    create_resources('::cron', $cron['jobs'])
  }

  if ($groups) {
    ::group { $groups: }
  }

  if ($users) {
    create_resources('::user', $users)
  }
}
