# JRuby ActiveRecord connection checkout regression

This repo is to demonstrate a performance regression observed when using Rails 6.1 with JRuby 9.3 (and the associated active record jdbc postgres library)

An example database `largedb` is generated using the included ruby script `./generate_largedb_schema.rb` which generates a schema with a table called `things` with 200 columns, and 15 other tables with 100 columns each.

The JRuby version is locked to `9.3.13.0`, but MRI `2.7.8`,`3.1.4` and `3.3.0` are used as counter examples for Rails 6.1.

Only log level = `info` is used for regular testing.

NOTE: There is an interesting performance hit observed when using `log_level=:debug` and Rails 6.1 with JRuby that is not present in any other version.

# Variables (see bench.sh for configuration)

| Name | Set Value | Notes |
| --- | --- | --- |
| `DATABASE` | largedb | database to load schema into |
| `RUNS_PER_LOOP` | 10 | the number of connection calls for the selected pool |
| `LOOPS` | 10-10000 | The number of loops ran, each loop selects one pool |
| `NUMBER_OF_POOLS` | 5 | The number of database pools to create | 

# How to run

Run `./bench.sh`

# M1 MBP results

```
macOS Sonoma 14.3
Postgresql 13.13
JDK-17
```

### JRuby -  Rails 4.2 
| Run count | Time |
| --- | --- |
| 1000 | 2.94 |
| 5000 | 8.71 |
| 10000 | 9.23 |
| 20000 | 14.13 |

### JRuby -  Rails 6.1 with `databaseMetadataCacheFieldsMiB=0`
| Run count | Time |
| --- | --- |
| 1000 | 18.39 |
| 5000 | 86.0 |
| 10000 | 172.79 |
| 20000 | 328.26 |

### JRuby - Rails 6.1 with `databaseMetadataCacheFieldsMiB=5`
| Run count | Time |
| --- | --- |
| 1000 | 4.95 |
| 5000 | 17.74 |
| 10000 | 29.07 |
| 20000 | 58.48 |

### JRuby - Rails 6.1 with `databaseMetadataCacheFieldsMiB=1`
| Run count | Time |
| --- | --- |
| 1000 | 5.12 |
| 5000 | 18.29 |
| 10000 | 28.59 |
| 20000 | 43.98 |

### Ruby 2.7.8 - Rails 6.1
| Run count | Time |
| --- | --- |
| 1000 | 2.58 |
| 5000 | 7.32 |
| 10000 | 15.05 |
| 20000 | 54.13 |

### Ruby 3.1.4 - Rails 6.1
| Run count | Time |
| --- | --- |
| 1000 | 1.12 |
| 5000 | 7.99 |
| 10000 | 18.95 |
| 20000 | 38.07 |

### Ruby 3.3.0 - Rails 6.1
| Run count | Time |
| --- | --- |
| 1000 | 1.76 |
| 5000 | 8.6 |
| 10000 | 18.26 |
| 20000 | 38.64 |
