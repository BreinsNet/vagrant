#!/bin/bash

if [ -z $1 ]; then
  echo usage: $0 [environment]
  exit 1
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
