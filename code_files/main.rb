require_relative 'tank_store.rb'

# Doing
# Database creation and population
tanksDB = TanksDB.instance
# Create and populate db and percentiles
#tanksDB.db_create
#tanksDB.db_populate_all_configs
#tanksDB.db_create_percentile_tables
#tanksDB.write_percentiles_json

# TODO
# Add shot dispersion factors
# Add turret traverse

# Logging
tanks = TankStore.instance

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

query = tanksDB.db.execute("select name from tanks group by name order by name asc")
puts "Tanks in db: #{query.count}"

File.open("scores.txt", "w") do |file|
  tanks.each_tank do |t|
    file.write("#{t}: #{t.tank_score}\n")
  end
end
