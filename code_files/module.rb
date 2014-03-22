
class Module

  attr_accessor :name, :weight, :stockModule, :topModule, :tier

  @@count = 0

  def initialize dict
    #puts dict
    mass_assign = ["name", "weight", "stockModule", "topModule", "tier"]
    mass_assign.each do |att|
      instance_variable_set("@#{att}", dict[att])
    end
    @@count += 1
  end 
  
  def self.count
    @@count
  end

  def to_s
    @name
  end

end
