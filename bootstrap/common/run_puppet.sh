#!/bin/bash

# Parse variables
if [[ -z $1 ]];then
  echo usage: "$0 [apply|agent]"
  exit 1
fi

# Run puppet 
case $1 in
  'apply')
    echo "INFO: Run puppet apply"
    /vagrant/tools/run_puppet_apply.sh >> /vagrant/logs/output.log 2>&1
    ;;
  'agent')
    if [[ -z $2 ]];then
      echo usage: "$0 agent [puppetmaster]"
      exit 1
    fi
    echo "INFO: Run puppet agent"
    /vagrant/tools/run_puppet_agent.sh $2 >> /vagrant/logs/output.log 2>&1
    ;;
  *)
    echo 'Invalid option'
    exit 1
    ;;
esac

if [[ $? -eq 2 || $? -eq 0 ]]; then
  exit 0
else
  exit 1
fi
