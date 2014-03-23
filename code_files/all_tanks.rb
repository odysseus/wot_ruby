require 'fileutils'
require 'singleton'
require 'json'
require './tier.rb'
require './tank.rb'

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
  end

  # Using define method to dynamically create the instance.tier1,
  # instance.tier2, etc. accessor methods
  (1..10).each do |n|
    define_method("tier#{n}") do
      @tiers[n-1]
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
