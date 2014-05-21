#!/bin/bash

if [ -z $1 ]; then
  echo usage: $0 [puppet server] [environment]
  exit
fi

if [ ! -z $2 ]; then
  ENVIRONMENT="--environment $2"
fi

puppet agent -t --server $1 $ENVIRONMENT
