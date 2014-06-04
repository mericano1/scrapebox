##Make sure all the packages are up to date

Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/node/node-default/bin/" ],
    timeout   => 0,
}

class { 'apt':
  always_apt_update    => true,
  update_timeout       => undef
}

#Set system timezone to UTC
class { "timezone":
  timezone => 'UTC',
}

class { 'python':
  version    => '2.7',
  pip        => true,
  dev        => true,
  virtualenv => false,
  gunicorn   => false,
}

#Note, manually installing python dev, as above package doesn't seem to do it
$mypackages = ["libxml2-dev", "libxslt-dev", "python-dev", "libffi-dev"]
package {$mypackages:
  ensure    => "installed"
}->
python::requirements { '/vagrant/requirements.txt': }

vcsrepo { "/opt/scraping/${repo}":
  ensure => latest,
  provider => git,
  source => "https://github.com/scrapinghub/portia.git",
  revision => 'master'
}

exec { "install_portia":
    command => "pip install -r requirements.txt",
    cwd    => "/opt/scraping/slyd"
}

exec { "run_portia" : 
    command => "twistd -n slyd" ,
    cwd    => "/opt/scraping/slyd",
    require     => Exec['install_portia']
}

