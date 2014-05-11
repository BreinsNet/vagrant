#!/bin/bash

echo "INFO: puppet bootstrap"

# Script error handling and output redirect
set -e                               # Fail on error
set -o pipefail                      # Fail on pipes
exec >> /vagrant/logs/output.log     # stdout to log file
exec 2>&1                            # stderr to log file
set -x

# Parse variables
if [[ -z $1 ]];then
  echo usage: "$0 hiera_git_repo"
  exit 1
fi

# Install dpendency gems
gem install \
 curb \
 r10k \
 system_timer \
 deep_merge

# Deploy hiera data
git clone $1 /etc/puppet/hieradata

# Create necessary links:
ln -s /etc/puppet/hieradata/misc/hiera.yaml /etc/puppet/hiera.yaml
ln -s /etc/puppet/hieradata/misc/r10k.yaml /etc/r10k.yaml

# Deploy puppet modules
r10k deploy environment -v -p
