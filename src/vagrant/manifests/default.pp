group { 'puppet': ensure => 'present' }

exec {'apt-get-update':
  command => '/usr/bin/apt-get update',
  timeout => 0,
}
Exec["apt-get-update"] -> Package <| |>

# ec2-add-keypair complains if timezone is wrong
file { "/etc/localtime":
    ensure => "/usr/share/zoneinfo/UTC"
}

package { 'git-core':            
    ensure => 'installed',
}

package { 'unzip':            
    ensure => 'installed',
}

package { 'ec2-api-tools':            
    ensure => 'installed',
}

# Required for installing certain Perl modules
package { 'make':            
    ensure => 'installed',
}

exec { "clone_repo_lab-stack":
    cwd => '/home/vagrant',
    command => 'git clone https://github.com/TWInfraTraining/lab-stack.git',
    user => "vagrant",
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    require => Package["git-core"],
    unless => "/usr/bin/test -d /home/vagrant/lab-stack",
}

$content = '
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
export EC2_HOME=/usr/lib/ec2-api-tools
export EC2_PRIVATE_KEY=~/.ec2/pk.pem
export EC2_CERT=~/.ec2/cert.pem
export AWS_CREDENTIAL_FILE=~/.ec2/access.pl
export AWS_CREDENTIALS_FILE=~/.ec2/access.pl
export AWS_CLOUDFORMATION_HOME=~/aws-cfn-tools
export PERL5LIB=~/aws-ses-tools/bin
export PATH=$PATH:~/aws-cfn-tools/bin:~/aws-ses-tools/bin
#export SES_FROM_EMAIL=CHANGE_ME_!!!
'

file { "/home/vagrant/.bash_profile":
    content => $content,
    owner => "vagrant",
    group => "vagrant",
}

file { "/home/vagrant/.ec2":
    ensure => "directory",
    owner => "vagrant",
    group => "vagrant",
}

file { "/home/vagrant/.ec2/access.pl":
    ensure => "present",
    owner => "vagrant",
    group => "vagrant",
}

exec { "get-aws-cfn-tools":
    cwd => '/tmp',
    command => 'wget https://s3.amazonaws.com/cloudformation-cli/AWSCloudFormation-cli.zip',
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    unless => "/usr/bin/test -s /tmp/AWSCloudFormation-cli.zip",
}

exec { "extract-aws-cfn-tools":
    cwd => '/home/vagrant',
    command => 'unzip /tmp/AWSCloudFormation-cli.zip',
    user => "vagrant",
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    require => [Package["unzip"], Exec["get-aws-cfn-tools"]],
    unless => "/usr/bin/test -d /home/vagrant/aws-cfn-tools",
}

exec { "move-aws-cfn-tools":
    cwd => '/home/vagrant',
    command => 'mv AWSCloudFormation-* aws-cfn-tools',
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    require => Exec["extract-aws-cfn-tools"],
    unless => "/usr/bin/test -d /home/vagrant/aws-cfn-tools",
}

exec { "get-aws-ses-tools":
    cwd => '/tmp',
    command => 'wget http://d36cz9buwru1tt.cloudfront.net/catalog/attachments/ses-tools-2012-06-26.zip',
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    unless => "/usr/bin/test -s /tmp/ses-tools-2012-06-26.zip",
}

file { "/home/vagrant/aws-ses-tools":
    ensure => 'directory',
    owner => "vagrant",
    group => "vagrant",
}

exec { "extract-aws-ses-tools":
    cwd => '/home/vagrant/aws-ses-tools',
    command => 'unzip /tmp/ses-tools-2012-06-26.zip',
    user => "vagrant",
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    require => [Package["unzip"], Exec["get-aws-ses-tools"], File["/home/vagrant/aws-ses-tools"]],
    unless => "/usr/bin/test -d /home/vagrant/aws-ses-tools/bin",
}

# Perl modules needed for SES tools
exec { "initCPAN":
    command =>  "wget -O - http://cpanmin.us | perl - --self-upgrade",
    path => "/usr/local/bin/:/usr/bin/:/bin/",
    creates  => "/usr/local/bin/cpanm",
    require => Package["make"],
  }

define cpan_load() {
    exec { "cpanLoad${title}":
      command => "cpanm --reinstall $name",
      path => "/usr/local/bin/:/usr/bin/:/bin/",
      #unless  => "perl -I.cpan -M$title -e 1",
      require => Exec["initCPAN"],
    }
  }

cpan_load { "LWP": }
cpan_load { "Net::SSL": }
cpan_load { "Digest::SHA": }
cpan_load { "URI::Escape": }
cpan_load { "Mozilla::CA": }
cpan_load { "Bundle::LWP": }
cpan_load { "LWP::Protocol::https": }
cpan_load { "MIME::Base64": }
cpan_load { "Crypt::SSLeay": }

