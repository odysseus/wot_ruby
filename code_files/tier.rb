require_relative './tank_group.rb'

class Tier

  attr_reader :lightTanks, :mediumTanks, :heavyTanks, :tankDestroyers, :SPGs,
    :types
  attr_accessor :db, :name

  def initialize dict
    @lightTanks = TankGroup.new(dict["lightTank"]) if dict["lightTank"]
    @mediumTanks = TankGroup.new(dict["mediumTank"]) if dict["mediumTank"]
    @heavyTanks = TankGroup.new(dict["heavyTank"]) if dict["heavyTank"]
    @tankDestroyers = TankGroup.new(dict["AT-SPG"]) if dict["AT-SPG"]
    @SPGs = TankGroup.new(dict["SPG"]) if dict["SPG"]

    @lightTanks.db = @db if @lightTanks
    @mediumTanks.db = @db if @mediumTanks
    @heavyTanks.db = @db if @heavyTanks
    @tankDestroyers.db = @db if @tankDestroyers
    @SPGs.db = @db if @SPGs

    @types = []
    @types.push(@lightTanks) if @lightTanks
    @types.push(@mediumTanks) if @mediumTanks
    @types.push(@heavyTanks) if @heavyTanks
    @types.push(@tankDestroyers) if @tankDestroyers
    @types.push(@SPGs) if @SPGs
  end

  types = [:lightTanks, :mediumTanks, :heavyTanks, :tankDestroyers, :SPGs]
  types.each do |type|
    define_method(type) do
      instance_variable_get("@#{type}").group
    end
  end

  def to_s
    @name
  end

  def each
    @types.each { |type| yield type }
  end

end
