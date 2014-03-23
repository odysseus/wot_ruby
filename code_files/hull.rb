require './module.rb'
require './gun.rb'

class Hull 

  attr_accessor :frontArmor, :sideArmor, :rearArmor, :gun, :viewRange,
    :availableGuns, :weight

  @@hulls = 0

  def initialize dict
    armor = [:frontArmor, :sideArmor, :rearArmor]
    armor.each do |att|
      instance_variable_set("@#{att}", Armor.new(dict[att.to_s]))
    end
    if dict["availableGuns"]
      @availableGuns = []
      available_guns_data = dict["availableGuns"]
      available_guns_data.each do |key, value|
        @availableGuns.push(Gun.new(value))
      end
      @viewRange = dict[:viewRange]
    end
    @@hulls += 1
  end

  def self.count
    @@hulls
  end

end
