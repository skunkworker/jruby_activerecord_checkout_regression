require 'pry'

def bench_times(pools, runs = 100)
  start = Time.now
  runs.times do
    pool = pools.sample
    conn = pool.checkout
    conn.execute("select 1=1")
    pool.checkin(conn)
  end
  puts "took #{Time.now-start} to run #{runs} times"
end

def build_db_config
  config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result, aliases: true)[Rails.env]["primary"].symbolize_keys

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

20.times do
  @pools << build_connection_pool
end

bench_times(@pools, 5_000)

