#!/bin/bash
set -e;
source ~/.rvm/scripts/rvm;

# Set JRUBY_OPTS for server mode
export JRUBY_OPTS=" -J-Djava.security.egd=file:/dev/./urandom -J-XX:+UseG1GC -J-XX:+UseStringDeduplication -J-Xms2048m -J-Xmx3584m -J-server --disable:did_you_mean"

export RUN_COUNT=30000;
export POOL_COUNT=1;

cd rails_42;
bundle;
echo "Running rails 4.2"
rails runner ../bench_42.rb

cd ../rails_61_jruby;
bundle;
echo "Running rails 6.1"
rails runner ../bench_61.rb
