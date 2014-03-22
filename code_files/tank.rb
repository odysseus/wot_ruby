require 'json'
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

  attr_accessor :name, :hull, :turret, :engine, :radio, :suspension, 
    :availableEngines, :availableRadios, :availableTurrets, 
    :availableSuspensions, :hasTurret, :premiumTank, :available, :gunArc, 
    :crewLevel, :speedLimit, :baseHitpoints, :nation, :tier, :type, 
    :stockWeight, :camoValueStationary, :camoValueMoving, :camoValueShooting

  @@count = 0

  def initialize dict
    # variables that can be mass assigned from the JSON
    mass_assign = [:name, :premiumTank, :available, :gunArc, :available, 
                   :crewLevel, :speedLimit, :baseHitpoints, :nation, :tier,
                   :type, :stockWeight]
    mass_assign.each do |att|
      instance_variable_set("@#{att}", dict[att.to_s])
    end
    camo_values = dict[:camoValues.to_s]
    @camoValueStationary = camo_values[0]
    @camoValueMoving = camo_values[1]
    @camoValueShooting = camo_values[2]
    @hasTurret = dict["turreted"]

    # Hull
    @hull = Hull.new(dict["hull"])

    # Turrets
    if @hasTurret
      @availableTurrets = []
      turrets_data = dict["turrets"]
      turrets_data.each do |k,v|
        @availableTurrets.push(Turret.new(v))
      end
    end

    # Engines
    @availableEngines = []
    engines_data = dict["engines"]
    engines_data.each do |k,v|
      @availableEngines.push(Engine.new(v))
    end

    # Radios
    @availableRadios = []
    radios_data = dict["radios"]
    radios_data.each do |k,v|
      @availableRadios.push(Radio.new(v))
    end

    # Suspensions
    @availableSuspensions = []
    suspensions_data = dict["suspensions"]
    suspensions_data.each do |k,v|
      @availableSuspensions.push(Suspension.new(v))
    end


    @@count += 1
  end

  def to_s
    "#{@name}"
  end

  def self.count
    @@count
  end

end
