require_relative './tank.rb'

class TankGroup

  attr_accessor :group, :db

  def initialize dict
    @group = []
    dict.each do |k,v|
      tank = Tank.new(v)
      tank.db = @db
      @group.push(tank)
    end
  end

  def self.to_s
    "TankGroup"
  end

  def first
    @group.first
  end

  def each
    @group.each { |tank| yield tank }
  end

end
