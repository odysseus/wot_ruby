require 'json'
require_relative './tank_store.rb'
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

  attr_accessor :name, :hull, :type, :turret, :engine, :radio, :suspension, 
    :availableEngines, :availableRadios, :availableTurrets, :gun, 
    :availableSuspensions, :hasTurret, :premiumTank, :available, :gunArc, 
    :crewLevel, :speedLimit, :baseHitpoints, :nation, :tier, :type, 
    :stockWeight, :camoValueStationary, :camoValueMoving, :camoValueShooting,
    :db

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
    @hull.db = @db

    # Turrets
    if @hasTurret
      @availableTurrets = []
      turrets_data = dict["turrets"]
      turrets_data.each do |k,v|
        turret = Turret.new(v)
        turret.db = @db
        @availableTurrets.push(turret)
      end
    end

    # Engines
    @availableEngines = []
    engines_data = dict["engines"]
    engines_data.each do |k,v|
      engine = Engine.new(v)
      engine.db = @db
      @availableEngines.push(engine)
    end

    # Radios
    @availableRadios = []
    radios_data = dict["radios"]
    radios_data.each do |k,v|
      radio = Radio.new(v)
      radio.db = @db
      @availableRadios.push(radio)
    end

    # Suspensions
    @availableSuspensions = []
    suspensions_data = dict["suspensions"]
    suspensions_data.each do |k,v|
      suspension = Suspension.new(v)
      suspension.db = @db
      @availableSuspensions.push(suspension)
    end
    set_weights
    set_all_values_top

    @@count += 1
  end

  def to_s
    "#{@name}"
  end

  def self.count
    @@count
  end

  def self.to_s
    "Tank"
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

  def each_config
    @availableRadios.each do |radio|
      @radio = radio
      @availableSuspensions.each do |suspension|
        @suspension = suspension
        @availableEngines.each do |engine|
          @engine = engine
          if @hasTurret
            @availableTurrets.each do |turret|
              @turret = turret
              turret.availableGuns.each do |gun|
                turret.gun = gun
                turret.gun.each_shell do |shell|
                  turret.gun.shell = shell
                  yield self if self.weight < @suspension.loadLimit
                end
              end
            end
          else
            @hull.availableGuns.each do |gun|
              hull.gun = gun
              hull.gun.each_shell do |shell|
                hull.gun.shell = shell
                yield self if self.weight < @suspension.loadLimit
              end
            end
          end
        end
      end
    end
  end

  # Converts stat weighting to sum up to 1.00 for consistency
  def converted_weights
    dict = TankStore.instance.weights[@type.to_s]
    total = 0.0
    final = {}
    dict.each do |k,v|
      total += v
    end
    dict.each do |k,v|
      final[k] = (v / total.to_f)
    end
    return final
  end

  def percentile_for key
    TankStore.instance.percentiles[key][eval("self.#{key}").to_f.to_s]
  end

  def tank_score
    score = 0
    converted_weights.each do |k,v|
      score += (((self.percentile_for(k) * 100) ** 3) * (v * 100)) / 10000
    end
    return score.round
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
    self.gun.aimTime.round(2)
  end

  def accuracy
    self.gun.accuracy.round(2)
  end

  def rateOfFire
    self.gun.rateOfFire.round(2)
  end

  def gunTraverseArc
    @gunArc
  end

  def gunDepression
    self.gun.gunDepression
  end

  def gunElevation
    self.gun.gunElevation
  end

  def autoloader
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
    if @hasTurret
      self.turret.traverseSpeed
    else
      self.suspension.traverseSpeed
    end
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
    (self.horsepower / self.weight).round(2)
  end

  def damagePerMinute
    (self.gun.rateOfFire * self.gun.damage).round
  end

  def reloadTime
    (60.0 / self.rateOfFire).round(3)
  end

  def alphaDamage
    self.gun.damage
  end

  def frontalHullArmor
    self.hull.frontArmor.thickness
  end

  def sideHullArmor
    self.hull.sideArmor.thickness
  end

  def rearHullArmor
    self.hull.rearArmor.thickness
  end

  def frontalTurretArmor
    if @hasTurret
      self.turret.frontArmor.thickness
    else
      self.hull.frontArmor.thickness
    end
  end

  def sideTurretArmor
    if @hasTurret
      self.turret.sideArmor.thickness
    else
      self.hull.sideArmor.thickness
    end
  end

  def rearTurretArmor
    if @hasTurret
      self.turret.rearArmor.thickness
    else
      self.hull.sideArmor.thickness
    end
  end

  def averageTerrainResistance
    self.suspension.average_terrain_resistance
  end

  def maxTraverseSpeed
    if @hasTurret
      self.suspension.traverseSpeed + self.turret.traverseSpeed
    else
      self.suspension.traverseSpeed
    end
  end

  def movementDispersionGun
    self.gun.movementDispersionGun
  end

  def movementDispersionSuspension
    self.suspension.movementDispersionSuspension
  end

  def combinedTerrainResistPercentile
    (percentile_for("softTerrainResistance") +
     percentile_for("mediumTerrainResistance") +
     percentile_for("hardTerrainResistance")) / 3.0
  end

  def avgTerrainResistance
    (softTerrainResistance + mediumTerrainResistance + hardTerrainResistance) / 3.0
  end

  # Database and Statistical Methods

  def sql_string_for_tank
    sql = "
      insert into 'tanks' 
        values(
          '#{self.name}',
          #{self.tier},
          #{self.weight},
          #{self.hitpoints},
          '#{self.gun.shell}',
          #{self.penetration},
          #{self.alphaDamage},
          #{self.accuracy},
          #{self.aimTime},
          #{self.rateOfFire},
          #{self.damagePerMinute},
          #{self.gunDepression},
          #{self.gunElevation},
          #{self.movementDispersionGun},
          #{self.autoloader},
          #{self.frontalHullArmor},
          #{self.sideHullArmor},
          #{self.rearHullArmor},
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
          #{self.softTerrainResistance},
          #{self.movementDispersionSuspension},
          #{self.frontalTurretArmor},
          #{self.sideTurretArmor},
          #{self.rearTurretArmor},
          #{self.turretTraverse});"
    return sql
  end

end
