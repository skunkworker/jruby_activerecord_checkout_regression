NUMBER_OF_POOLS = ENV["POOL_COUNT"]&.to_i || 1
RUN_COUNT = ENV["RUN_COUNT"]&.to_i || 10_000
CONNS_PER_RUN = ENV["CONNS_PER_RUN"]&.to_i || 20

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
  config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)[Rails.env].symbolize_keys

  config[:adapter_spec] = ArJdbc::PostgreSQL
  config[:adapter_class] = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  config[:driver] = "org.postgresql.Driver"

  config[:url] = "jdbc:postgresql://#{config[:host]}:5432/#{config[:database]}"

  config
end

def build_connection_specification
  ::ActiveRecord::ConnectionAdapters::ConnectionSpecification.new(build_db_config,"postgresql_connection")
end


# https://api.rubyonrails.org/v4.2/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html

@pools = []

def build_connection_pool
  ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(build_connection_specification)
end

NUMBER_OF_POOLS.times do
  @pools << build_connection_pool
end

bench_times(@pools)

