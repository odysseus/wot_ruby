require './tank_group.rb'

class Tier

  attr_reader :lightTanks, :mediumTanks, :heavyTanks, :tankDestroyers, :SPGs

  def initialize dict
    @lightTanks = TankGroup.new(dict["lightTank"]) if dict["lightTank"]
    @mediumTanks = TankGroup.new(dict["mediumTank"]) if dict["mediumTank"]
    @heavyTanks = TankGroup.new(dict["heavyTank"]) if dict["heavyTank"]
    @tankDestroyers = TankGroup.new(dict["AT-SPG"]) if dict["AT-SPG"]
    @SPGs = TankGroup.new(dict["SPG"]) if dict["SPG"]
  end

  types = [:lightTanks, :mediumTanks, :heavyTanks, :tankDestroyers, :SPGs]
  types.each do |type|
    define_method(type) do
      instance_variable_get("@#{type}").group
    end
  end

end
