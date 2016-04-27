#! /bin/bash
set -u
set -e

PUPPET_BIN_DIR="/usr/bin/"
PUPPET_SERVER="puppetmaster.gd1.qingcloud.com"
PUPPET_SERVER_IP="192.168.104.2"


printf "=====================================\n"
printf "add master to /etc/hosts .......... \n"
printf "=====================================\n"

if ! grep "${PUPPET_SERVER}" /etc/hosts; then
  echo "${PUPPET_SERVER_IP}     ${PUPPET_SERVER}" >> /etc/hosts 
fi

printf "=====================================\n"
printf "add puppet yum for this agent.......\n"
printf "=====================================\n"


cat /etc/redhat-release > /tmp/redhat-release

if grep  'release 5' /tmp/redhat-release; then
  cat >/etc/yum.repos.d/puppet.repo <<EOF
[puppet]
name=puppet
baseurl=http://192.168.104.2/el5
enable=1
gpgcheck=0
priority=1
EOF
elif grep  'release 6' /tmp/redhat-release; then
  cat >/etc/yum.repos.d/puppet.repo <<EOF
[puppet]
name=puppet
baseurl=http://192.168.104.2/foreman
enable=1
gpgcheck=0
priority=1
EOF
else
  printf "the OS release is not supported by this script \n"
fi




printf "=====================================\n"
printf "start to install puppet packages........ \n"
printf "=====================================\n"

yum install -y puppet


# Sets server, certname and any custom puppet.conf flags passed in to the script


printf "=====================================\n"
printf "Sets server, certname and any custom puppet.conf \n"
printf "=====================================\n"

puppet_conf="$("${PUPPET_BIN_DIR?}/puppet" config print confdir)/puppet.conf"



"${PUPPET_BIN_DIR?}/puppet" config set server "${PUPPET_SERVER}" --section main


if [ "$("${PUPPET_BIN_DIR?}/facter" hostname | "${PUPPET_BIN_DIR?}/ruby" -e 'puts STDIN.read.downcase')" = "localhost" ]; then
  "${PUPPET_BIN_DIR?}/puppet" config set certname $("${PUPPET_BIN_DIR?}/facter" ipaddress | "${PUPPET_BIN_DIR?}/ruby" -e 'puts STDIN.read.downcase') --section agent
else
  "${PUPPET_BIN_DIR?}/puppet" config set certname $("${PUPPET_BIN_DIR?}/facter" fqdn | "${PUPPET_BIN_DIR?}/ruby" -e 'puts STDIN.read.downcase') --section agent
fi



# To ensure the new config settings take place, restart the service by stopping and starting it again
printf "=====================================\n"
printf "restart puppet agent ...... \n"
printf "=====================================\n"


"${PUPPET_BIN_DIR?}/puppet" agent --test

"${PUPPET_BIN_DIR?}/puppet" agent --test


exit 0

