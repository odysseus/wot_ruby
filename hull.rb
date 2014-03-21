require './module.rb'

class Hull < Module

  attr_reader :frontArmor, :sideArmor, :rearArmor, :gun, :viewRange,
    :availableGuns

end
