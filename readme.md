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
| `SCHEMA_COUNT` | 1-1000 | Sets the number of schemas to use (generated from `generate_largedb_schema.rb`) |

# How to run

Run `./bench.sh`

# M1 MBP results

```
macOS Sonoma 14.3
Postgresql 13.13
JDK-17
```

Variables

```
export DATABASE="largedb";
export RUNS_PER_LOOP=10;
export NUMBER_OF_POOLS=5;
export SCHEMA_COUNT=1000;
```

### JRuby -  Rails 4.2 
| Run count | Time |
| --- | --- |
| 1000 | 4.09 |
| 5000 | 7.11 |
| 10000 | 9.68 |
| 20000 | 14.0 |

### JRuby -  Rails 6.1 with `databaseMetadataCacheFieldsMiB=2`
| Run count | Time |
| --- | --- |
| 1000 | 21.54 |
| 5000 | 103.09 |
| 10000 | 201.32 |
| 20000 | 356.61 |

### JRuby - Rails 6.1 with `databaseMetadataCacheFieldsMiB=0`
| Run count | Time |
| --- | --- |
| 1000 | 22.37 |
| 5000 | 104.77 |
| 10000 | 200.07 |
| 20000 | 399.97 |

### JRuby - Rails 6.1 with `databaseMetadataCacheFieldsMiB=5`
| Run count | Time |
| --- | --- |
| 1000 | 17.56 |
| 5000 | 74.41 |
| 10000 | 147.27 |
| 20000 | 281.73 |

### Ruby 2.7.8 - Rails 6.1
| Run count | Time |
| --- | --- |
| 1000 | 3.14 |
| 5000 | 17.3 |
| 10000 | 32.28 |
| 20000 | 66.52 |

### Ruby 3.1.4 - Rails 6.1
| Run count | Time |
| --- | --- |
| 1000 | 2.7 |
| 5000 | 14.44 |
| 10000 | 29.42 |
| 20000 | 58.74 |

### Ruby 3.3.0 - Rails 6.1
| Run count | Time |
| --- | --- |
| 1000 | 2.61 |
| 5000 | 13.92 |
| 10000 | 29.0 |
| 20000 | 60.04 |
