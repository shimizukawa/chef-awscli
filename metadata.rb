maintainer       "Takayuki SHIMIZUKAWA"
maintainer_email "shimizukawa@beproud.jp"
license          "Apache 2.0"
description      "Installs/Configures myrecipe"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"
recipe           "awscli::default", "install awscli package into user site-packages"
recipe           "awscli::hosts", "setup /etc/hosts from data_bags"

depends "hostsfile"
