require 'fileutils'
require 'singleton'
require 'json'
require 'sqlite3'
require_relative './tier.rb'
require_relative './tank.rb'
require_relative './tank_store.rb'

class TanksDB
  include Singleton

  attr_accessor :db, :stats

  def initialize
    @db = SQLite3::Database.new("../db/stats.db")
    @stats = [
      ["hitpoints", "desc", "hitpoints"],
      ["penetration", "desc", "penetration"],
      ["damage", "desc", "alphaDamage"],
      ["accuracy", "asc", "accuracy"],
      ["aim_time", "asc", "aimTime"],
      ["rate_of_fire", "desc", "rateOfFire"],
      ["damage_per_minute", "desc", "damagePerMinute"],
      ["gun_depression", "asc", "gunDepression"],
      ["gun_elevation", "desc", "gunElevation"],
      ["movement_dispersion_gun", "asc", "movementDispersionGun"],
      ["frontal_hull", "desc", "frontallHullArmor"],
      ["side_hull", "desc", "sideHullArmor"],
      ["rear_hull", "desc", "rearHullArmor"],
      ["camo_stationary", "desc", "camoValueStationary"],
      ["camo_moving", "desc", "camoValueMoving"],
      ["camo_shooting", "desc", "camoValueShooting"],
      ["view_range", "desc", "viewRange"],
      ["gun_arc", "desc", "gunTraverseArc"],
      ["specific_power", "desc", "specificPower"],
      ["fire_chance", "asc", "fireChance"],
      ["signal_range", "desc", "signalRange"],
      ["hull_traverse", "desc", "hullTraverse"],
      ["speed_limit", "desc", "speedLimit"],
      ["hard_terrain_resist", "asc", "hardTerrainResistance"],
      ["medium_terrain_resist", "asc", "mediumTerrainResistance"],
      ["soft_terrain_resist", "asc", "softTerrainResistance"],
      ["average_terrain_resist", "asc", "avgTerrainResistance"],
      ["movement_dispersion_suspension", "asc", "movementDispersionSuspension"],
      ["frontal_turret", "desc", "frontalTurretArmor"],
      ["side_turret", "desc", "sideTurretArmor"],
      ["rear_turret", "desc", "rearTurretArmor"],
      ["turret_traverse", "desc", "turretTraverse"]
    ]
  end

  def self.to_s
    "TanksDB"
  end

  def db_create
    @db.execute("drop table if exists tanks")
    @db.execute <<-SQL
      create table if not exists tanks (
        name varchar(140),
        tier int,
        weight float,
        hitpoints int,
        shell_type varchar(140),
        penetration int,
        damage int,
        accuracy float,
        aim_time float,
        rate_of_fire float,
        damage_per_minute int,
        gun_depression int,
        gun_elevation int,
        movement_dispersion_gun float,
        autoloader boolean,
        frontal_hull int,
        side_hull int,
        rear_hull int,
        camo_stationary float,
        camo_moving float,
        camo_shooting float,
        view_range int,
        gun_arc int,
        specific_power float,
        fire_chance float,
        signal_range int,
        hull_traverse int,
        speed_limit int,
        hard_terrain_resist float,
        medium_terrain_resist float,
        soft_terrain_resist float,
        average_terrain_resist float,
        movement_dispersion_suspension float,
        frontal_turret int,
        side_turret int,
        rear_turret int,
        turret_traverse int
      );
    SQL
  end

  def db_populate_stock_configs
    tanks = TankStore.instance
    tanks.each_tank do |tank|
      tank.set_all_values_stock
      @db.execute(tank.sql_string_for_tank)
    end
  end

  def db_populate_top_configs
    tanks = TankStore.instance
    tanks.each_tank do |tank|
      tank.set_all_values_top
      @db.execute(tank.sql_string_for_tank)
    end
  end

  def db_populate_all_configs
    tanks = TankStore.instance
    tanks.each_tank do |tank|
      # print the name of the tank to show progress
      puts tank
      tank.each_config do |config|
        @db.execute(config.sql_string_for_tank)
      end
    end
  end

  def fetch_unique_values_for(key, order)
    @db.execute("select #{key} from tanks 
                group by #{key} 
                order by #{key} #{order}").flatten
  end

  # Pass an ordered array of unique values (best to worst) to
  # calculate the percentile for each value
  def calculate_percentiles arr
    final = []
    count = arr.count
    arr.each_with_index do |v,i|
      percentile = (count - i) / count.to_f
      final.push([v,percentile])
    end
    return final
  end

  def db_create_percentile_tables
    @stats.each do |stat_arr|
      stat = stat_arr[0]
      order = stat_arr[1]

      # Log the name to show progress
      puts stat

      # Array with all the unique values in the order of best to worst
      query = fetch_unique_values_for(stat, order)
      percentiles = calculate_percentiles(query)

      # Create the table to house the stats
      @db.execute("drop table if exists #{stat}_percentiles")
      @db.execute("create table if not exists #{stat}_percentiles (
                  value float,
                  percentile float
                  );")

      # And add all the values from the percentiles array
      percentiles.each do |p|
        @db.execute("insert into #{stat}_percentiles values
                    ('#{p[0]}', #{p[1]});")
      end
    end
  end

  def all_percentiles_hash
    final = {}
    @stats.each do |s|
      stat = s[0]
      name = s[2]
      final[name] = {}
      query = @db.execute("select * from #{stat}_percentiles")
      query.each do |q|
        final[name][q[0].to_s] = q[1]
      end
    end
    return final
  end

  def all_percentiles_json
    JSON.pretty_generate(all_percentiles_hash)
  end

  def write_percentiles_json
    File.open("../db/percentiles.json", "w") do |file|
      file.write(all_percentiles_json)
    end
    puts "Percentile JSON written"
  end

end
