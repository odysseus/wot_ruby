require_relative './module.rb'
require_relative './shell.rb'

class Gun < Module

  attr_accessor :shells, :round, :rateOfFire, :accuracy, :aimTime,
    :gunDepression, :gunElevation, :autoloader, :roundsInDrum,
    :timeBetweenShots, :shell

  @@guns = 0

  def initialize dict
    super
    mass_assign = [:rateOfFire, :accuracy, :aimTime, :gunDepression, :gunElevation]
    mass_assign.each do |att|
      instance_variable_set("@#{att}", dict[att.to_s])
    end
    if dict["autoloader"]
      @autoloader = 1
    else
      @autoloader = 0
    end
    @shells = []
    shells_data = dict["shells"]
    shells_data.each do |s|
      @shells.push(Shell.new(s))
    end
    @shell = @shells[0]
    @@guns += 1
  end

  def self.count
    @@guns
  end
  
  def self.to_s
    "Gun"
  end

  def penetration
    self.shell.penetration
  end

  def damage
    self.shell.damage
  end

end
