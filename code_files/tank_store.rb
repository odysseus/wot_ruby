require 'fileutils'
require 'singleton'
require 'json'
require 'sqlite3'
require_relative './tanks_db.rb'
require_relative './tier.rb'
require_relative './tank.rb'

class TankStore
  include Singleton

  attr_reader :tiers, :percentiles, :weights
  attr_accessor :db

  def initialize
    @db = SQLite3::Database.new("#{$path}/db/stats.db")
    @percentiles = JSON.parse(File.read("#{$path}/db/percentiles.json"))
    @weights = JSON.parse(File.read("#{$path}/db/weights.json"))
    @tiers = []
    (1..10).each do |t|
      path = "../tier_files/tier#{t}.json"
      tier_json = JSON.parse(IO.read(path))["tier#{t}"]
      tier = Tier.new(tier_json)
      tier.name = "Tier #{t}"
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

  def each
    (1..10).each do |i|
      yield @tiers[i-1]
    end
  end

  def each_tank &block
    self.each do |tier|
      tier.each do |type|
        type.each do |tank|
          yield tank
        end
      end
    end
  end

end
