class profile::postgresql  {
  $package_name = $facts['os']['family'] ? {
    'RedHat' => 'postgresql-server',
    'Debian' => 'postgresql',
    default  => 'postgresql', # Assuming default for other OS families
  }

  package { $package_name:
    ensure => installed,
  }

  package { 'postgresql-contrib':
    ensure => installed,
  }

  package { 'postgresql-client':
    ensure => installed,
  }

  exec { 'initdb':
    command     => '/usr/bin/postgresql-setup initdb',
    refreshonly => true,
  }

  service { 'postgresql':
    ensure  => running,
    enable  => true,
    require => [Package[$package_name], Exec['initdb']],
  }

  file { '/etc/postgresql/14/main/pg_hba.conf':
    ensure  => file,
    content => "host    all             all             0.0.0.0/0            md5\n",
    require => Service['postgresql'],
  }

  file { '/etc/postgresql/14/main/postgresql.conf':
    ensure  => file,
    content => "listen_addresses = '*'\n",
    require => Service['postgresql'],
  }



  exec { 'set_postgres_password':
    command => 'sudo -u postgres psql -c "ALTER USER postgres PASSWORD \'TPSrep0rt!\';"',
    unless  => 'sudo -u postgres psql -c "SELECT 1" | grep -q 1',
    require => Service['postgresql'],
    refreshonly => true,
  }

 }
