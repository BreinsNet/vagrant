#!/bin/bash

if [ -z $1 ]; then
  echo usage: $0 [puppet server] [environment]
  exit
fi

if [ ! -z $2 ]; then
  ENVIRONMENT="--environment $2"
fi

echo "INFO: running puppet agent on environment $2 , puppet master is: $1"

if [[ $(id -u) -eq 0 ]];then
  LOG_FILE=/var/log/bootstrap.log
else
  LOG_FILE=/vagrant/logs/bootstrap.log
fi

# Script error handling and output redirect
exec >> $LOG_FILE                    # stdout to log file
exec 2>&1                            # stderr to log file
set -x

puppet agent -t --server $1 $ENVIRONMENT

if [[ $? -ne 4 ]]; then
  exit 1
else
  exit 0
fi

