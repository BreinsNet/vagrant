#!/bin/bash

echo "INFO: puppet bootstrap"

# Script error handling and output redirect
set -e                               # Fail on error
set -o pipefail                      # Fail on pipes
exec >> /vagrant/logs/output.log     # stdout to log file
exec 2>&1                            # stderr to log file
set -x

ln -s /vagrant/tools/run_puppet_apply.sh /usr/bin
ln -s /vagrant/tools/run_puppet_agent.sh /usr/bin
