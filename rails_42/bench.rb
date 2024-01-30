NUMBER_OF_POOLS = 20
RUN_COUNT = 10_000

def bench_times(pools)
  start = Time.now
  RUN_COUNT.times do
    pool = pools.sample
    conn = pool.checkout
    conn.execute("select 1=1")
    pool.checkin(conn)
  end
  puts "took #{Time.now-start} to run #{RUN_COUNT} times"
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

