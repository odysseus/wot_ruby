class Shell

  attr_reader :shellType, :penetration, :damage, :cost
  attr_accessor :db

  @@shells = 0

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
    @@shells += 1
  end
  
  def self.count
    @@shells
  end

  def self.to_s
    "Shell"
  end

  def to_s
    if @shellType == :gold
      "Gold"
    elsif @shellType == :he
      "HE"
    else
      "Normal"
    end
  end

end
