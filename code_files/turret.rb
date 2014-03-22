require './module.rb'
require './armor.rb'

class Turret < Module

  attr_accessor :viewRange, :traverseSpeed, :additionalHP, :frontArmor, 
    :sideArmor, :rearArmor, :availableGuns, :gun

  @@turrets = 0

  def initialize dict
    super
    mass_assign = [:viewRange, :traverseSpeed, :additionalHP]
    mass_assign.each do |att|
      instance_variable_set("@#{att}", dict[att.to_s])
    end
    armor = [:frontArmor, :sideArmor, :rearArmor]
    armor.each do |att|
      instance_variable_set("@#{att}", Armor.new(dict[att.to_s]))
    end
    @availableGuns = []
    guns_data = dict["availableGuns"]
    guns_data.each do |key,value|
      @availableGuns.push(Gun.new(value))
    end
    @@turrets += 1
  end

  def self.count
    @@turrets
  end

end
