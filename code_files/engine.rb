require_relative './module.rb'

class Engine < Module

  attr_accessor :horsepower, :fireChance

  @@engines = 0

  def initialize dict
    super
    @horsepower = dict[:horsepower.to_s]
    @fireChance = dict[:fireChance.to_s]
    @@engines += 1
  end


  def self.count
    @@engines
  end

end
