require 'fileutils'
require 'singleton'
require 'json'
require 'sqlite3'
require_relative './tier.rb'
require_relative './tank.rb'

class TankStore
  include Singleton

  attr_reader :tiers
  attr_accessor :db

  def initialize
    @db = SQLite3::Database.new("tanks.db")
    @tiers = []
    (1..10).each do |t|
      path = "../tier_files/tier#{t}.json"
      tier_json = JSON.parse(IO.read(path))["tier#{t}"]
      tier = Tier.new(tier_json)
      tier.db = @db
      @tiers.push(tier)
    end
  end

  # Using define_method to dynamically create the instance.tier1,
  # instance.tier2, etc. accessor methods
  (1..10).each do |n|
    define_method("tier#{n}") do
      @tiers[n-1]
    end
  end

  def self.to_s
    "TankStore"
  end

  def db_create
    @db.execute <<-SQL
      create table if not exists tanks (
        name varchar(140),
        weight float,
        hitpoints int,
        penetration int,
        damage int,
        accuracy float,
        aim_time float,
        rate_of_fire float,
        damage_per_minute int,
        gun_depression int,
        gun_elevation int,
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
        frontal_turret int,
        side_turret int,
        rear_turret int
      );
      SQL
  end

  def db_populate
    tanks = TankStore.instance
    tanks.tiers.each do |tier|
      tier.types.each do |type|
        type.group.each do |tank|
          puts tank.sql_string_for_tank
          @db.execute(tank.sql_string_for_tank)
        end
      end
    end
  end

end

tanks = TankStore.instance

puts "Tanks: #{Tank.count}"
puts "Hulls: #{Hull.count}"
puts "Turret: #{Turret.count}"
puts "Guns: #{Gun.count}"
puts "Engines: #{Engine.count}"
puts "Radios: #{Radio.count}"
puts "Suspenstions: #{Suspension.count}"
puts "Modules: #{Module.count}"
puts "\n"

test = tanks.tier8.mediumTanks.first

# DON'T TOUCH! THE DATABASE IS GOOD NOW!
#tanks.db_create
#tanks.db_populate

query = tanks.db.execute("select name, penetration from tanks order by penetration desc")
puts query.to_s
