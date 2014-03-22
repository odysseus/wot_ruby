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
    :availableEngines, :availableRadios, :availableTurrets, :gun, 
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
    set_all_values_top
    #validate

    @@count += 1
  end

  def set_all_values_top
    modArr = [:availableEngines, :availableSuspensions, :availableRadios]
    modNames = [:engine, :suspension, :radio]
    modArr.each do |modules|
      self.send(modules).each_with_index do |mod,i|
        if mod.topModule
          instance_variable_set("@#{modNames[i]}", mod)
        end
      end
    end
    if @hasTurret
      @availableTurrets.each do |tur|
        if tur.topModule
          self.turret = tur
          self.turret.availableGuns.each do |g|
            self.turret.gun = g if g.topModule
          end
        end
      end
    else
      self.hull.availableGuns.each do |g|
        self.hull.gun = g if g.topModule
      end
    end
  end

  def to_s
    "#{@name}"
  end

  def self.count
    @@count
  end

  def validate
    result = true

    # floatKeys need nonnull and nonzero values
    floatKeys = ["tier", "crewLevel", "baseHitpoints", "gunArc", 
                 "gunElevation", "speedLimit", "camoValueStationary", 
                 "camoValueMoving", "camoValueShooting", "viewRange"]
    floatKeys.each do |key|
      unless self.send(key) > 0
        puts "#{@name} is missing #{key}"
        result = false
      end
    end

    # presenceKeys needs nonnull values
    presenceKeys = ["name", "nation", "type", "hasTurret", "premiumTank", 
                    "hull", "engine", "radio", "suspension", "cost",
                    "gunDepression"]
    presenceKeys.each do |key|
      unless self.send(key)
        puts "#{@name} is missing #{key}"
        result = false
      end
    end
  end

  def gun
    if @hasTurret
      return self.turret.gun
    else
      return self.hull.gun
    end
  end

  def penetration
    return gun.penetration
  end

  def aimTime
    return self.gun.aimTime
  end

end
