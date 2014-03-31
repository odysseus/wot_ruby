require_relative './module.rb'
require_relative './shell.rb'

class Gun < Module

  attr_accessor :shells, :round, :rateOfFire, :accuracy, :aimTime,
    :gunDepression, :gunElevation, :autoloader, :roundsInDrum,
    :timeBetweenShots, :shell, :movementDispersionGun

  @@guns = 0

  def initialize dict
    super
    mass_assign = [:rateOfFire, :accuracy, :aimTime, :gunDepression, 
                   :gunElevation]
    mass_assign.each do |att|
      instance_variable_set("@#{att}", dict[att.to_s])
    end
    @movementDispersionGun = dict["dispersion"]["gunMovement"].to_f
    if dict["autoloader"]
      @autoloader = 1
    else
      @autoloader = 0
    end
    @shells = []
    shells_data = dict["shells"]
    shells_data.each do |s|
      shell = Shell.new(s)
      shell.db = @db
      @shells.push(shell)
    end
    @shell = @shells[0]
    @@guns += 1
  end

  def each_shell
    @shells.each do |s|
      yield s
    end
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
