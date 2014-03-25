require_relative './module.rb'

class Radio < Module

  attr_accessor :signalRange

  @@radios = 0

  def initialize dict
    super
    @signalRange = dict[:signalRange.to_s]
    @@radios += 1
  end

  def self.count
    @@radios
  end

end
