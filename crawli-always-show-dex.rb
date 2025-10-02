module BallHandlers
  def self.onCatch(ball,battle,pokemon)
    if pbIsSnagBall?(ball) && !battle.opponent && !$Trainer.pokedex.dexList[pokemon.species][:owned?]
      $Trainer.pokedex.setOwned(pokemon)
      if $Trainer.pokedex.canViewDex
        pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pokemon.name))
        @scene.pbShowPokedex(pokemon.species) 
      end
    end
    if OnCatch[ball]
      OnCatch.trigger(ball,battle,pokemon)
    end
  end
end
