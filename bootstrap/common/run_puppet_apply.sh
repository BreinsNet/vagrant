#!/bin/bash

if [ -z $1 ]; then
  echo usage: $0 [environment] [disable_log]
  exit 1
fi

echo "INFO: running puppet apply on environment $1"

if [[ $(id -u) -eq 0 ]];then
  LOG_FILE=/var/log/bootstrap.log
else
  LOG_FILE=/vagrant/logs/bootstrap.log
fi

if [[ -z $2 ]]; then

  # Script error handling and output redirect
  exec >> $LOG_FILE                    # stdout to log file
  exec 2>&1                            # stderr to log file
  set -x

fi

if which rvm > /dev/null 2>&1; then
  source /etc/profile.d/rvm.sh
  rvm use system
fi

ENVIRONMENT=$1

puppet apply \
  --detailed-exitcodes \
  --modulepath=/etc/puppet/environments/$ENVIRONMENT/modules:/etc/puppet/environments/$ENVIRONMENT/custom \
  --hiera_config=/etc/puppet/hiera.yaml \
  /vagrant/manifests/default.pp

if [[ $? -ne 2 ]]; then
  exit 1
else
  exit 0
fi
