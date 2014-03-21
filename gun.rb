require './module.rb'

class Gun < Module

  attr_reader :shells, :round, :rateOfFire, :accuracy, :aimTime,
    :gunDepression, :gunElevation, :autoloader, :roundsInDrum,
    :timeBetweenShots, :normalRound, :heRound, :goldRound

end
