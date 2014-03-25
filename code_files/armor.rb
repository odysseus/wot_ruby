
class Armor

  attr_reader :thickness, :angle

  def initialize arr
    @thickness = arr[0]
    @angle = arr[1]
  end

  def self.to_s
    "Armor"
  end

  def to_s
    @thickness
  end

end
