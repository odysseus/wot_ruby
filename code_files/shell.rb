
class Shell

  attr_reader :shellType, :penetration, :damage, :cost

  def initialize sarr
    @penetration = sarr[0]
    @damage = sarr[1]
    @cost = sarr[2]
    if sarr[3]
      @shellType = :gold
    elsif sarr[4] == "high_explosive"
      @shellType = :he
    else
      @shellType = :normal
    end
  end

end
