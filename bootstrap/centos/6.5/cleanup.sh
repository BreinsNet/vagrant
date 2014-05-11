#!/bin/bash

echo "INFO: Clean up"

# Script error handling and output redirect
set -e                               # Fail on error
set -o pipefail                      # Fail on pipes
exec >> /vagrant/logs/output.log     # stdout to log file
exec 2>&1                            # stderr to log file
set -x

# Clean up puppetlabs packages 
# through the normal apt-get upgrade path
rpm -e puppetlabs-release
