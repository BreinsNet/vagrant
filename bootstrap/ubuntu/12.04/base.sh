#!/bin/bash

echo "INFO: Base bootstrap"

if [[ $(id -u) -eq 0 ]];then
  LOG_FILE=/var/log/bootstrap.log
else
  LOG_FILE=/vagrant/logs/bootstrap.log
fi

# Script error handling and output redirect
set -e                               # Fail on error
set -o pipefail                      # Fail on pipes
exec >> $LOG_FILE                    # stdout to log file
exec 2>&1                            # stderr to log file
set -x

# Parse variables
if [[ -z $1 ]] || [[ -z $2 ]];then
  echo usage: "$0 puppet_version fqdn"
  exit 1
fi

PUPPET_VERSION=$1
FQDN=$2
HOSTNAME=$(echo $FQDN|cut -d'.' -f1)

# Workaround for sudo to work with ssh forward agent, only needed in vagrant:
echo "Defaults    env_keep += \"SSH_AUTH_SOCK\"" > /etc/sudoers.d/root_ssh_agent
chmod 0440 /etc/sudoers.d/root_ssh_agent

# Configure ssh keys and config:
[[ ! -d /root/.ssh ]] && mkdir /root/.ssh && chmod 700 /root/.ssh
echo StrictHostKeyChecking no > /root/.ssh/config

# Necesary answers for iptables-persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections


# Upgrade the system
apt-get clean
apt-get update
apt-get -y upgrade

# Install puppet
wget -q https://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update

apt-get -y install \
  puppet=$PUPPET_VERSION \
  puppet-common=$PUPPET_VERSION \
  libcurl4-gnutls-dev \
  rubygems \
  git

# Network configuration:
hostname ${HOSTNAME}

cat << EOF > /etc/hosts
127.0.0.1    localhost.localdomain   localhost

$(facter ipaddress) $FQDN $(facter hostname)

EOF

iptables -F
