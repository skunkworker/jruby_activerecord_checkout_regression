NUMBER_OF_POOLS = ENV["NUMBER_OF_POOLS"]&.to_i || 1
RUN_COUNT = ENV["RUN_COUNT"]&.to_i || 10_000
CONNS_PER_RUN = ENV["CONNS_PER_RUN"]&.to_i || 5

def bench_times(pools)
  start = Time.now
  RUN_COUNT.times do
    pool = pools.sample

    conns = []
    CONNS_PER_RUN.times do
      conn = pool.checkout
      conn.execute("select 1=1")
      conns << conn
    end

    conns.each{|c| pool.checkin(c)}
  end
  puts "took #{(Time.now-start).round(2)} to run #{RUN_COUNT*CONNS_PER_RUN} times"
end

def build_db_config
  if ENV["YAML_ALIASES"]
    config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result, aliases: true)[Rails.env]["primary"].symbolize_keys
  else
    config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)[Rails.env]["primary"].symbolize_keys
  end
  ::ActiveRecord::DatabaseConfigurations::HashConfig.new(::Rails.env, "primary", config)
end

def build_pool_config
  ::ActiveRecord::ConnectionAdapters::PoolConfig.new(::ActiveRecord::Base,build_db_config)
end


# https://api.rubyonrails.org/v6.1/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html

@pools = []

def build_connection_pool
  ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(build_pool_config)
end

NUMBER_OF_POOLS.times do
  @pools << build_connection_pool
end

bench_times(@pools)

