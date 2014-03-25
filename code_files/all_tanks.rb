require 'fileutils'
require 'singleton'
require 'json'
require './tier.rb'
require './tank.rb'
require 'sqlite3'

class TankStore
  include Singleton

  attr_reader :tiers

  def initialize
    @tiers = []
    (1..10).each do |t|
      path = "../tier_files/tier#{t}.json"
      tier_json = JSON.parse(IO.read(path))["tier#{t}"]
      tier = Tier.new(tier_json)
      @tiers.push(tier)
    end
    @db = SQLite3::Database.new("tanks.db")
  end

  # Using define_method to dynamically create the instance.tier1,
  # instance.tier2, etc. accessor methods
  (1..10).each do |n|
    define_method("tier#{n}") do
      @tiers[n-1]
    end
  end

  def db_create
    @db.execute <<-SQL
      create table if not exists tanks (
        name varchar(140),
        weight float,
        frontal_hull int,
        side_hull int,
        rear_hull int,
        camo_stationary float,
        camo_moving float,
        camo_shooting float,
        view_range int,
        gun_arc int,
        frontal_turret int,
        side_turret int,
        rear_turret int,
        specific_power float,
        fire_chance float,
        signal_range int,
        hull_traverse int,
        speed_limit int,
        hard_terrain_resist float,
        medium_terrain_resist float,
        soft_terrain_resist float
      );
      SQL
  end

  def db_populate
    tanks = TankStore.instance
    tanks.tiers.each do |tier|
      tier.types.each do |type|
        type.group.each do |tank|
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
puts test
puts test.radio
puts test.gun
puts test.engine
puts test.suspension
puts test.turret

test.db_create
test.db_populate
