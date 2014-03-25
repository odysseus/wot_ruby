require_relative './module.rb'

class Suspension < Module

  attr_accessor :loadLimit, :traverseSpeed, :hardTerrainResistance, 
    :mediumTerrainResistance, :softTerrainResistance

  @@suspensions = 0

  def initialize dict
    super
    @loadLimit = dict[:loadLimit.to_s]
    @traverseSpeed = dict[:traverseSpeed.to_s]
    # Terrain resistance number array
    terrain_resist = dict[:terrainResistance.to_s]
    @hardTerrainResistance = terrain_resist[0]
    @mediumTerrainResistance = terrain_resist[1]
    @softTerrainResistance = terrain_resist[2]
    
    @@suspensions += 1
  end

  def self.count
    @@suspensions
  end

end
