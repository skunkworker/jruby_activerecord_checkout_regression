NUMBER_OF_TABLES = 15
SCHEMA_FILENAME = "largedb-schema.sql"

@generate_column_lambdas = [
  -> (i) { "col_#{i} text" },
  -> (i) { "col_#{i} numeric(14,2)" },
  -> (i) { "col_#{i} boolean" },
  -> (i) { "col_#{i} integer" },
  -> (i) { "col_#{i} timestamp without time zone" },
]

def create_table(table_name, number_of_columns)
  str = "CREATE TABLE #{table_name} (\n"
  columns = number_of_columns.times.collect do |i|
    @generate_column_lambdas.sample.call(i)
  end.join(",\n")

  str+columns+"\n);"
end

::File.open(SCHEMA_FILENAME, 'w') do |file|
  table_name = "things"
  file.write(create_table(table_name, 200))
  file.write("\n")

  NUMBER_OF_TABLES.times do |i|
    table_name = "table#{i}"
    file.write(create_table(table_name, 100))
    file.write("\n")
  end
end