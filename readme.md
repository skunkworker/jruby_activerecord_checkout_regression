# JRuby ActiveRecord connection checkout regression

Vanilla Rails applications with postgres as the adapter, pointing to the `postgres` database with no relations. The rails logger was set to point to `/dev/null`


```
./compare.sh
```


Early results 

```
Running rails 4.2 with jruby-9.3.13.0
log_level=debug
took 0.75 to run 500 times
took 1.12 to run 2500 times
took 1.59 to run 5000 times
took 3.48 to run 10000 times
took 3.66 to run 25000 times
took 5.83 to run 50000 times
log_level=info
took 0.65 to run 500 times
took 1.01 to run 2500 times
took 1.48 to run 5000 times
took 1.89 to run 10000 times
took 3.23 to run 25000 times
took 5.5 to run 50000 times
log_level=fatal
took 0.66 to run 500 times
took 0.95 to run 2500 times
took 1.34 to run 5000 times
took 1.85 to run 10000 times
took 3.25 to run 25000 times
took 5.31 to run 50000 times

Running rails 6.1 with jruby-9.3.13.0
log_level=debug
took 2.14 to run 500 times
took 4.03 to run 2500 times
took 5.85 to run 5000 times
took 9.08 to run 10000 times
took 18.44 to run 25000 times
took 34.51 to run 50000 times
log_level=info
took 1.56 to run 500 times
took 2.18 to run 2500 times
took 2.84 to run 5000 times
took 3.68 to run 10000 times
took 5.89 to run 25000 times
took 7.95 to run 50000 times
log_level=fatal
took 2.02 to run 500 times
took 2.61 to run 2500 times
took 2.47 to run 5000 times
took 3.62 to run 10000 times
took 6.04 to run 25000 times
took 7.75 to run 50000 times
```
