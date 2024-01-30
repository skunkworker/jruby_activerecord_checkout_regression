#!/bin/bash
set -e;
source ~/.rvm/scripts/rvm;

export RUBYOPT="-W0";

# Set JRUBY_OPTS for server mode
export JRUBY_OPTS=" -J-Djava.security.egd=file:/dev/./urandom -J-XX:+UseG1GC -J-XX:+UseStringDeduplication -J-Xms2048m -J-Xmx3584m -J-server --disable:did_you_mean"

counts=(100 500 1000 2000 5000 10000)
# log_levels=(debug fatal)
log_levels=(debug info fatal)

export CONNS_PER_RUN=5;
export NUMBER_OF_POOLS=10;

(
  cd rails_42;
  printf "\nRunning rails 4.2 with jruby-9.3.13.0\n"

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${counts[@]}"
    do
      RUN_COUNT=$value rails runner ../bench_42.rb;
    done;
  done;
)

(
  cd rails_61_jruby;
  printf "\nRunning rails 6.1 with jruby-9.3.13.0\n"

  for log_level in "${log_levels[@]}"
  do
    export LOG_LEVEL=$log_level;
    echo "log_level=$log_level"
    for value in "${counts[@]}"
    do
      RUN_COUNT=$value rails runner ../bench_61.rb;
    done;
  done;
)


# (
#   cd rails_61_278;
#   printf "\n**Running rails 6.1 with Ruby 2.7.8\n"

#   for log_level in "${log_levels[@]}"
#   do
#     export LOG_LEVEL=$log_level;
#     echo "log_level=$log_level"
#     for value in "${counts[@]}"
#     do
#       RUN_COUNT=$value rails runner ../bench_61.rb;
#     done;
#   done;
# )


# (
#   cd rails_61_314;
#   printf "\n**Running rails 6.1 with Ruby 3.1.4\n"
#   export YAML_ALIASES=true;

#   for log_level in "${log_levels[@]}"
#   do
#     export LOG_LEVEL=$log_level;
#     echo "log_level=$log_level"
#     for value in "${counts[@]}"
#     do
#       RUN_COUNT=$value rails runner ../bench_61.rb;
#     done;
#   done;
# )

# (
#   cd rails_61_330;
#   printf "\n**Running rails 6.1 with Ruby 3.3.0\n"
#   export YAML_ALIASES=true;

#   for log_level in "${log_levels[@]}"
#   do
#     export LOG_LEVEL=$log_level;
#     echo "log_level=$log_level"
#     for value in "${counts[@]}"
#     do
#       RUN_COUNT=$value rails runner ../bench_61.rb;
#     done;
#   done;
# )

