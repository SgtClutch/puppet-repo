class profile::postgresql (
  $postgres_password = 'TPSrep0rt!',
) {
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

  file { '/var/lib/pgsql/data/pg_hba.conf':
    ensure  => file,
    content => "host    all             all             0.0.0.0/0            md5\n",
    require => Service['postgresql'],
  }

  file { '/var/lib/pgsql/data/postgresql.conf':
    ensure  => file,
    content => "listen_addresses = '*'\n",
    require => Service['postgresql'],
  }

  exec { 'set_postgres_password':
    command => "/usr/bin/psql -U postgres -c \"ALTER USER postgres WITH PASSWORD '${postgres_password}';\"",
    unless  => "/usr/bin/psql -U postgres -c 'SELECT 1' | grep -q 1",
    require => Service['postgresql'],
  }

 
}