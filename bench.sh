#!/bin/bash
set -e;
source ~/.rvm/scripts/rvm;

# General Variables
export RUBYOPT="-W0";
export JRUBY_OPTS=" -J-Djava.security.egd=file:/dev/./urandom -J-XX:+UseG1GC -J-XX:+UseStringDeduplication -J-Xms2048m -J-Xmx3584m -J-server --disable:did_you_mean"
export IDLE_TIMEOUT=100;

# Testing variables
export DATABASE="largedb";
export RUNS_PER_LOOP=10;
export NUMBER_OF_POOLS=5;
export SCHEMA_COUNT=1000;

# Generate the test database
psql -c "drop database if exists $DATABASE;"
psql -c "create database $DATABASE;"
psql $DATABASE < largedb-schema.sql;

# Run variable arrays
loops=(100 500 1000 2000) # add 10000 for a much longer run
log_levels=(info)

printf "\n***** Running with variables:\n RUNS_PER_LOOP=$RUNS_PER_LOOP, NUMBER_OF_POOLS=$NUMBER_OF_POOLS, DATABASE=$DATABASE, IDLE_TIMEOUT=$IDLE_TIMEOUT, SCHEMA_COUNT=$SCHEMA_COUNT, loops=${loops[*]}, log_levels=${log_levels[*]}"

(
  cd rails_42;
  printf "\nRunning rails 4.2 with jruby-9.3.13.0\n"

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)

(
  cd rails_61_jruby;
  printf "\nRunning rails 6.1 with jruby-9.3.13.0 with DB_METADATA_CACHE_FIELDS_MIB=2 \n"
  export DB_METADATA_CACHE_FIELDS_MIB="2";

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)


(
  cd rails_61_jruby;
  printf "\nRunning rails 6.1 with jruby-9.3.13.0  with DB_METADATA_CACHE_FIELDS_MIB=0 \n"
  export DB_METADATA_CACHE_FIELDS_MIB="0";

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)

(
  cd rails_61_jruby;
  printf "\nRunning rails 6.1 with jruby-9.3.13.0 with DB_METADATA_CACHE_FIELDS_MIB=5 \n"
  export DB_METADATA_CACHE_FIELDS_MIB="5";

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)


(
  cd rails_61_278;
  printf "\n**Running rails 6.1 with Ruby 2.7.8\n"

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)

(
  cd rails_61_314;
  printf "\n**Running rails 6.1 with Ruby 3.1.4\n"
  export YAML_ALIASES=true;

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)

(
  cd rails_61_330;
  printf "\n**Running rails 6.1 with Ruby 3.3.0\n"
  export YAML_ALIASES=true;

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${loops[@]}"
    do
      LOOPS=$value rails runner ../bench.rb;
    done;
  done;
)


