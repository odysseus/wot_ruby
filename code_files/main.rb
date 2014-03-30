require 'sqlite3'
require 'romans'
require_relative './tanks_db.rb'
require_relative './tier.rb'
require_relative './tank.rb'
require_relative 'all_tanks.rb'

tanks = TankStore.instance

# Logging
puts "Tanks: #{Tank.count}"
puts "Hulls: #{Hull.count}"
puts "Turret: #{Turret.count}"
puts "Guns: #{Gun.count}"
puts "Engines: #{Engine.count}"
puts "Radios: #{Radio.count}"
puts "Suspensions: #{Suspension.count}"
puts "Modules: #{Module.count}"

rows = tanks.db.execute("select count(*) from tanks")[0][0]
puts "\nRows in db: #{rows}\n"

query = tanks.db.execute("select name from tanks group by name order by name asc")
puts "Tanks in db: #{query.count}"

# Doing
# Database creation and population
#tanksDB = Object::TanksDB.instance
#tanksDB.db_create
#tanksDB.db_populate_all_configs
#tanksDB.db_create_percentile_tables

query = tanks.db.execute("select * from dbname.sqlite_master where type='table'")
puts query
