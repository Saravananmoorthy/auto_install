#! /bin/bash
set -u
set -e

printf "=====================================\n"
printf "starting to install and please wait  \n"
printf "=====================================\n"


PUPPET_BIN_DIR="/usr/bin/"
PUPPET_SERVER="`hostname --fqdn`"
PUPPET_SERVER_IP="`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`"


printf "=====================================\n"
printf "add master to /etc/hosts ..........  \n"
printf "=====================================\n"

if ! grep "${PUPPET_SERVER}" /etc/hosts; then
  echo "${PUPPET_SERVER_IP}     ${PUPPET_SERVER}" >> /etc/hosts 
fi

printf "=====================================\n"
printf "add native yum for this computer.......\n"
printf "=====================================\n"

mkdir -p /etc/yum.repos.d/bak
cd /etc/yum.repos.d/
mv *.repo ./bak

cat /etc/redhat-release > /tmp/redhat-release

if grep  'release 5' /tmp/redhat-release; then
  cat >/etc/yum.repos.d/puppetlabs.repo <<EOF
[puppetlabs]
name=puppetlabs
baseurl=file:///root/repo5
enable=1
gpgcheck=0
priority=1
EOF
elif grep  'release 6' /tmp/redhat-release; then
  cat >/etc/yum.repos.d/puppetlabs.repo <<EOF
[puppetlabs]
name=puppetlabs
baseurl=file:///root/repo6
enable=1
gpgcheck=0
priority=1
EOF
else
  printf "the OS release is not supported by this script \n"
fi


printf "=====================================\n"
printf "start to install foreman........ \n"
printf "=====================================\n"

yum -y install epel-release 
yum -y install foreman-installer
foreman-installer


printf "=========================================\n"
printf "use default system  yum for this computer\n"
printf "=========================================\n"

cd /etc/yum.repos.d/bak
mv *.repo /etc/yum.repos.d/
mv /etc/yum.repos.d/puppetlabs.repo /etc/yum.repos.d/bak

exit 0