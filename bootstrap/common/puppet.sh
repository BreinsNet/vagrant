#!/bin/bash

echo "INFO: puppet masterless bootstrap"

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
if [[ -z $1 ]];then
  echo usage: "$0 hiera_git_repo"
  exit 1
fi

GEM_LIST="curb r10k system_timer deep_merge"
# Install dpendency gems
if [[ $(gem list|grep -E "$(echo $GEM_LIST|sed s/\ /\|/g)"|wc -l) -ne $(echo $GEM_LIST|wc -w) ]] ; then
  gem install $GEM_LIST
fi

# Deploy hiera data
[[ ! -d /etc/puppet/hieradata/.git ]] && git clone $1 /etc/puppet/hieradata 
cd /etc/puppet/hieradata && git pull

# Create necessary links:
[[ ! -h /etc/puppet/hiera.yaml ]] && ln -s /etc/puppet/hieradata/misc/hiera.yaml /etc/puppet/hiera.yaml
[[ ! -h /etc/r10k.yaml ]] && ln -s /etc/puppet/hieradata/misc/r10k.yaml /etc/r10k.yaml

# Deploy puppet modules
r10k deploy environment -v -p
