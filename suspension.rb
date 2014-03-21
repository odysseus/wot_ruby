require './module.rb'

class Suspension < Module

  attr_reader :loadLimit, :traverseSpeed, :hardTerrainResistance, 
    :mediumTerrainResistance, :softTerrainResistance

end
