NUMBER_OF_POOLS = ENV["NUMBER_OF_POOLS"]&.to_i || 1
LOOPS = ENV["LOOPS"]&.to_i || 100
RUNS_PER_LOOP = ENV["RUNS_PER_LOOP"]&.to_i || 20
@pools = []

def run_benchmark
  start = Time.now
  LOOPS.times do
    pool = @pools.sample

    conns = []
    RUNS_PER_LOOP.times do
      conn = pool.checkout
      conn.execute("select 1=1")
      conns << conn
    end
    conns.each{|c| pool.checkin(c)}
  end
  puts "took #{(Time.now-start).round(2)} to run #{LOOPS*RUNS_PER_LOOP} times against #{ENV.fetch('DATABASE', 'postgres')}"
end

def run_benchmark_with_find
  start = Time.now
  LOOPS.times do
    pool = @pools.sample

    RUNS_PER_LOOP.times do
      pool.with_connection do
        ::Thing.first
      end
    end
  end
  puts "took #{(Time.now-start).round(2)} to run #{LOOPS*RUNS_PER_LOOP} times against #{ENV.fetch('DATABASE', 'postgres')}"
end

# https://api.rubyonrails.org/v6.1/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html
def rails_61_build_connection_pool
  if ENV["YAML_ALIASES"]
    config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result, aliases: true)[Rails.env]["primary"].symbolize_keys
  else
    config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)[Rails.env]["primary"].symbolize_keys
  end
  build_db_config = ::ActiveRecord::DatabaseConfigurations::HashConfig.new(::Rails.env, "primary", config)

  build_pool_config =   ::ActiveRecord::ConnectionAdapters::PoolConfig.new(::ActiveRecord::Base,build_db_config)

  ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(build_pool_config)
end

# https://api.rubyonrails.org/v4.2/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html
def rails_42_build_connection_pool
  config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)[Rails.env].symbolize_keys

  config[:adapter_spec] = ArJdbc::PostgreSQL
  config[:adapter_class] = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  config[:driver] = "org.postgresql.Driver"

  config[:url] = "jdbc:postgresql://#{config[:host]}:5432/#{config[:database]}"

  build_connection_specification = ::ActiveRecord::ConnectionAdapters::ConnectionSpecification.new(config,"postgresql_connection")

  ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(build_connection_specification)
end

NUMBER_OF_POOLS.times do
  if ::ActiveRecord::VERSION::MAJOR == 4 && ::ActiveRecord::VERSION::MINOR == 2
    @pools << rails_42_build_connection_pool
  elsif ::ActiveRecord::VERSION::MAJOR == 6 && ::ActiveRecord::VERSION::MINOR == 1
    @pools << rails_61_build_connection_pool
  end
end

run_benchmark_with_find
