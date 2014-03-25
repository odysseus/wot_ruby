require 'json'
require_relative './module.rb'
require_relative './hull.rb'
require_relative './turret.rb'
require_relative './gun.rb'
require_relative './engine.rb'
require_relative './suspension.rb'
require_relative './radio.rb'
require_relative './armor.rb'
require_relative './shell.rb'

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
    set_weights
    set_all_values_top

    @@count += 1
  end

  def set_all_values_top
    @availableEngines.each do |eng|
      @engine = eng if eng.topModule 
    end
    @availableSuspensions.each do |sus|
      @suspension = sus if sus.topModule
    end
    @availableRadios.each do |rad|
      @radio = rad if rad.topModule
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

  def set_all_values_stock
    @availableEngines.each do |eng|
      @engine = eng if eng.stockModule 
    end
    @availableSuspensions.each do |sus|
      @suspension = sus if sus.stockModule
    end
    @availableRadios.each do |rad|
      @radio = rad if rad.stockModule
    end
    if @hasTurret
      @availableTurrets.each do |tur|
        if tur.stockModule
          self.turret = tur
          self.turret.availableGuns.each do |g|
            self.turret.gun = g if g.stockModule
          end
        end
      end
    else
      self.hull.availableGuns.each do |g|
        self.hull.gun = g if g.stockModule
      end
    end
  end

  def set_weights
    set_all_values_stock
    self.hull.weight = (self.stockWeight * 1000) - self.gun.weight - 
      self.engine.weight - self.radio.weight - self.suspension.weight
    self.hull.weight -= self.turret.weight if @hasTurret
  end

  def to_s
    "#{@name}"
  end

  def self.count
    @@count
  end

  # Pass-Thru and Calculated Properties

  def gun
    if @hasTurret
      self.turret.gun
    else
      self.hull.gun
    end
  end

  def penetration
    self.gun.penetration
  end

  def aimTime
    self.gun.aimTime
  end

  def accuracy
    self.gun.accuracy
  end

  def rateOfFire
    self.gun.rateOfFire
  end

  def gunDepression
    self.gun.gunDepression
  end

  def gunElevation
    self.gun.gunElevation
  end

  def autoloader?
    self.gun.autoloader
  end

  def roundsInDrum
    self.gun.roundsInDrum
  end

  def drumReload
    self.gun.drumReload
  end

  def timeBetweenShots
    self.gun.timeBetweenShots
  end

  def burstDamage
    self.roundsInDrum * self.gun.damage
  end

  def burstLength
    self.roundsInDrum * self.timeBetweenShots
  end

  def loadLimit
    self.suspension.loadLimit
  end

  def viewRange
    if @hasTurret
      self.turret.viewRange
    else
      self.hull.viewRange
    end
  end

  def horsepower
    self.engine.horsepower
  end

  def fireChance
    self.engine.fireChance
  end

  def signalRange
    self.radio.signalRange
  end

  def hullTraverse
    self.suspension.traverseSpeed
  end

  def turretTraverse
    self.turret.traverseSpeed
  end

  def hardTerrainResistance
    self.suspension.hardTerrainResistance
  end

  def mediumTerrainResistance
    self.suspension.mediumTerrainResistance
  end

  def softTerrainResistance
    self.suspension.softTerrainResistance
  end

  def hitpoints
    if @hasTurret
      self.baseHitpoints + self.turret.additionalHP
    else
      self.baseHitpoints
    end
  end

  def weight
    final = self.hull.weight + self.gun.weight + self.suspension.weight + 
      self.radio.weight + self.engine.weight
    final += self.turret.weight if @hasTurret
    final /= 1000.0
  end

  def specificPower
    self.horsepower / self.weight
  end

  def damagePerMinute
    self.gun.rateOfFire * self.gun.damage
  end

  def reloadTime
    60.0 / self.rateOfFire
  end

  def alphaDamage
    self.gun.damage
  end

  def frontalHullArmor
    self.hull.frontArmor
  end

  def sideHullArmor
    self.hull.sideArmor
  end

  def rearHullArmor
    self.hull.rearArmor
  end

  def frontalTurretArmor
    self.turret.frontArmor
  end

  def sideTurretArmor
    self.turret.sideArmor
  end

  def rearTurretArmor
    self.turret.rearArmor
  end

  # Database and Statistical Methods
  
  # Sketching out what will be included in the TankScore calculations
  # Gun:
  #   0 - Penetration
  #   1 - Damage
  #   2 - Accuracy
  #   3 - Aim Time
  #   4 - Rate of Fire
  #   5 - Damage Per Minute
  #   6 - Gun Depression
  #   7 - Gun Elevation
  #   8 - Dummy Variable for Autoloaders
  # Hull:
  #   9 - Hitpoints
  #   10 - Weight
  #   11 - Frontal Hull
  #   12 - Side Hull
  #   13 - Rear Hull
  #   14 - Camo Value Stationary
  #   15 - Camo Value Moving
  #   16 - Camo Value Shooting
  #   17 - View Range
  #   18 - Gun Arc
  # Turret:
  #   19 - Frontal Turret
  #   20 - Side Turret
  #   21 - Rear Turret
  # Engine:
  #   22 - Specific Power
  #   23 - Fire Chance
  # Radio
  #   24 - Signal Range
  # Suspension
  #   25 - Hull Traverse
  #   26 - Speed Limit
  #   27 - Hard Terrain Resistance
  #   28 - Medium Terrain Resistance
  #   29 - Soft Terrain Resistance

  def sql_string_for_tank
    sql = "
      insert into 'tanks' 
        values(
          '#{self.name}',
          #{self.weight},
          #{self.frontalHullArmor.thickness},
          #{self.sideHullArmor.thickness},
          #{self.rearHullArmor.thickness},
          #{self.camoValueStationary},
          #{self.camoValueMoving},
          #{self.camoValueShooting},
          #{self.viewRange},
          #{self.gunArc},
          #{self.specificPower},
          #{self.fireChance},
          #{self.signalRange},
          #{self.hullTraverse},
          #{self.speedLimit},
          #{self.hardTerrainResistance},
          #{self.mediumTerrainResistance},
          #{self.softTerrainResistance},"
      if @hasTurret 
        sql << "
          #{self.frontalTurretArmor.thickness},
          #{self.sideTurretArmor.thickness},
          #{self.rearTurretArmor.thickness}"
      else
        sql << "
          null,
          null,
          null"
      end
      sql << ");"
      return sql
  end

end
