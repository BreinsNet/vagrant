#!/bin/bash

if which rvm > /dev/null 2>&1; then
  source /etc/profile.d/rvm.sh
  rvm use system
fi

puppet apply \
  --detailed-exitcodes \
  --modulepath=/etc/puppet/environments/production/modules:/etc/puppet/environments/production/custom \
  --hiera_config=/etc/puppet/hiera.yaml \
  /vagrant/manifests/default.pp
