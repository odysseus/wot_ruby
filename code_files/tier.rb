require './tank_group.rb'

class Tier

  attr_accessor :lightTanks, :mediumTanks, :heavyTanks, :tankDestroyers, :SPGs

  def initialize dict
    @lightTanks = TankGroup.new(dict["lightTank"]) if dict["lightTank"]
    @mediumTanks = TankGroup.new(dict["mediumTank"]) if dict["mediumTank"]
    @heavyTanks = TankGroup.new(dict["heavyTank"]) if dict["heavyTank"]
    @tankDestroyers = TankGroup.new(dict["AT-SPG"]) if dict["AT-SPG"]
    @SPGs = TankGroup.new(dict["SPG"]) if dict["SPG"]
  end

end
