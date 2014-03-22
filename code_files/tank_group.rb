require './tank.rb'

class TankGroup

  attr_accessor :group

  def initialize dict
    @group = []
    dict.each do |k,v|
      tank = Tank.new(v)
      @group.push(tank)
    end
  end

  def first
    @group.first
  end

end
