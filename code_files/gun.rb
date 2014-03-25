require_relative './module.rb'
require_relative './shell.rb'

class Gun < Module

  attr_accessor :shells, :round, :rateOfFire, :accuracy, :aimTime,
    :gunDepression, :gunElevation, :autoloader, :roundsInDrum,
    :timeBetweenShots, :normalRound, :heRound, :goldRound

  @@guns = 0

  def initialize dict
    super
    mass_assign = [:rateOfFire, :accuracy, :aimTime, :gunDepression, :gunElevation]
    mass_assign.each do |att|
      instance_variable_set("@#{att}", dict[att])
    end
    @shells = []
    shells_data = dict["shells"]
    shells_data.each do |s|
      @shells.push(Shell.new(s))
    end
    @@guns += 1
  end

  def self.count
    @@guns
  end

end
