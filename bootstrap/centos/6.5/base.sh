# Run params:

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

# Disable selinux:
sed -ri s/^SELINUX=.*/SELINUX=disabled/g /etc/sysconfig/selinux 
setenforce 0 || true

# Check if this has already been provisioned:
if rpm -qi puppet-$PUPPET_VERSION; then 
  exit 0
fi

# Workaround for sudo to work with ssh forward agent, only needed in vagrant:
echo "Defaults    env_keep += \"SSH_AUTH_SOCK\"" > /etc/sudoers.d/root_ssh_agent
chmod 0440 /etc/sudoers.d/root_ssh_agent

# Configure ssh keys and config:
[[ ! -d /root/.ssh ]] && mkdir /root/.ssh && chmod 700 /root/.ssh
echo StrictHostKeyChecking no > /root/.ssh/config

# Upgrade the system
yum clean metadata
yum upgrade -y

# Install puppet:
yum install -y -q \
  http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm \
  http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

yum install -y -q \
  puppet-$PUPPET_VERSION \
  ruby-devel \
  rubygems \
  libcurl-devel \
  git \
  gcc

# Network configuration:
hostname ${FQDN}

cat << EOF > /etc/hosts
127.0.0.1    localhost.localdomain   localhost

$(facter ipaddress) $FQDN $(facter hostname)

EOF

cat << EOF > /etc/sysconfig/network
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME=${FQDN}

EOF

# For some reason sometimes postfix is up but the service doesn't
# Detect it. So here we kill it. Puppet will later on start it
# again:
ps -fe|grep postfix |grep -v grep|awk '{print $2}'|xargs kill

iptables -F

