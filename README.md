# puppet-server

[![Build Status](https://travis-ci.org/teneleven/puppet-server.svg?branch=master)](https://travis-ci.org/teneleven/puppet-server)

Server setup provisioning scripts

For example (hiera.yaml):

```yaml
server:
  packages:
    - git
    - curl
    - vim-nox
  users:
    teneleven:
      groups: ['dev', 'sudo']
  acls:
    '/var/www':
      - 'u:www-data:rwX'
      - 'g:www-data:rwX'
    '/var/volumes/devops': []
  default_acls: ['g:dev:rwX']
```

Then, in your puppet manifest:

```puppet
node default {
    $server = hiera_hash('server', {})
    if (!empty($server)) {
      create_resources('class', { '::server' => $server })
    }
}
```

By default this will install the packages and setup the "teneleven" user with
the groups "dev" and "sudo". It will also setup the ACLs so that "/var/www" is
accessible by both "www-data" & "dev", and "/var/volumes/devops" is accessible
by "dev".

# Installation

Puppetfile:

```Puppetfile
#!/usr/bin/env ruby

forge "https://forgeapi.puppetlabs.com"

mod 'server',
  :git => 'git@github.com:teneleven/puppet-server.git'
```

Then do `librarian-puppet install`.
