#!/bin/bash

echo "INFO: Clean up"

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

# Clean up puppetlabs packages 
# through the normal apt-get upgrade path
if dpkg -l puppetlabs-release|grep ii; then
  apt-get purge -y puppetlabs-release
  apt-get clean && apt-get update
fi
