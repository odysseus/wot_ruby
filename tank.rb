require './module.rb'
require './hull.rb'
require './turret.rb'
require './gun.rb'
require './engine.rb'
require './suspension.rb'
require './radio.rb'
require './armor.rb'
require './shell.rb'

class Tank

  attr_reader :name, :hull, :turret, :engine, :radio, :suspension, 
    :availableEngines, :availableRadios, :availableTurrets,
    :availableSuspensions, :topWeight, :hasTurret, :premiumTank,
    :gunTraverseArc, :crewLevel, :speedLimit, :baseHitpoints, 
    :nationality, :tier, :type, :stockWeight, :camoValueStationary,
    :camoValueMoving, :camoValueShooting

  def initialize dict
    dict.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end if args.is_a? Hash
  end

end
