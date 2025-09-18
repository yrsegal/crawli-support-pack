class PokemonRegionMap

  alias :crawlifly_old_pbStartFlyScreen :pbStartFlyScreen

  def pbStartFlyScreen
    if BlindstepActive
      return Blindstep.flyMenu
    end
    return crawlifly_old_pbStartFlyScreen
  end
end
