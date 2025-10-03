module PokeBattle_BattleCommon

  def pbThrowPokeBall(idxPokemon,ball,rareness=nil,showplayer=false)
    itemname=getItemName(ball)
    battler=nil
    if pbIsOpposing?(idxPokemon)
      battler=self.battlers[idxPokemon]
    else
      battler=self.battlers[idxPokemon].pbOppositeOpposing
    end
    if battler.isFainted?
      battler=battler.pbPartner
    end
    oldform=battler.form
    battler.form=battler.pokemon.getForm(battler.pokemon)
    pbDisplayBrief(_INTL("{1} threw a {2}!",self.pbPlayer.name,itemname))
    if battler.isFainted?
      pbDisplay(_INTL("But there was no target..."))
      pbBallFetch(ball)
      return
    end
    if @opponent && (!pbIsSnagBall?(ball) || !battler.isShadow?)
      @scene.pbThrowAndDeflect(ball,1)
      if !($game_switches[:No_Catching] || battler.isbossmon || battler.issossmon)
        pbDisplay(_INTL("The Trainer blocked the Ball!\nDon't be a thief!"))
      else
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
      end
    else
      if $game_switches[:No_Catching] || battler.issossmon || (battler.isbossmon && (!battler.capturable || battler.shieldCount > 0)) 
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
        pbBallFetch(ball)
        return
      end
      pokemon=battler.pokemon
      species=pokemon.species
      rareness = pokemon.catchRate if !rareness
      rareness /= 2 if $game_variables[:LuckMoves] != 0
      a=battler.totalhp
      b=battler.hp
      rareness=BallHandlers.modifyCatchRate(ball,rareness,self,battler) 
      rareness +=1 if $PokemonBag.pbQuantity(:CATCHINGCHARM)>0
      rareness +=1 if Reborn && $PokemonBag.pbQuantity(:CATCHINGCHARM2)>0
      rareness +=1 if Reborn && $PokemonBag.pbQuantity(:CATCHINGCHARM3)>0
      rareness +=1 if Reborn && $PokemonBag.pbQuantity(:CATCHINGCHARM4)>0
      if (battler.isbossmon && battler.capturable && battler.shieldCount == 0)
        rareness += 3
      end
      x=(((a*3-b*2)*rareness)/(a*3))
      if battler.status== :SLEEP || battler.status== :FROZEN
        x=(x*2.5)
      elsif !battler.status.nil?
        x=(x*3/2)
      end
      #Critical Capture chances based on caught species'
      c=0
      if $Trainer
        mod = -3
        mod +=0.5 if $Trainer.pokedex.getOwnedCount>500
        mod +=0.5 if $Trainer.pokedex.getOwnedCount>400
        mod +=0.5 if $Trainer.pokedex.getOwnedCount>300
        mod +=0.5 if $Trainer.pokedex.getOwnedCount>200
        mod +=0.5 if $Trainer.pokedex.getOwnedCount>100
        mod +=0.5 if $Trainer.pokedex.getOwnedCount>30
        c=(x*(2**mod)).floor
      end
      shakes=0; critical=false; critsuccess=false
      if x>255 || BallHandlers.isUnconditional?(ball,self,battler)
        shakes=4
      else
        x=1 if x==0
        y = (65536/((255.0/x)**0.1875)).floor
        puts "c = #{c}; x = #{x}"
        percentage = (1/((255.0/x)**0.1875))**4
        puts "Catch chance: #{percentage*100}%"
        percentage = c/256.0 * (1/((255.0/x)**0.1875))
        puts "Crit chance: #{percentage*100}%"
        if pbRandom(256)<c
          critical=true
          if pbRandom(65536)<y
            critsuccess=true
            shakes=4
          end
        else
          shakes+=1 if pbRandom(65536)<y
          shakes+=1 if pbRandom(65536)<y
          shakes+=1 if pbRandom(65536)<y
          shakes+=1 if pbRandom(65536)<y
        end
      end
      shakes=4 if $DEBUG && Input.press?(Input::CTRL)
      @scene.pbThrow(ball,(critical) ? 1 : shakes,critical,critsuccess,battler.index,showplayer)
      case shakes
        when 0
          pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 1
          pbDisplay(_INTL("Aww... It appeared to be caught!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 2
          pbDisplay(_INTL("Aargh! Almost had it!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 3
          pbDisplay(_INTL("Shoot! It was so close, too!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 4
          # shadow catch should not be segmented like this
          @scene.pbWildBattleSuccess
          snag = pbIsSnagBall?(ball)
          pbDisplayPaused(_INTL("Gotcha! {1} was caught!",pokemon.name))
          @scene.pbThrowSuccess
          if snag && @opponent
            8.times do
              @scene.sprites["battlebox#{battler.index}"].opacity-=32
              @scene.pbGraphicsUpdate
            end
            pbRemoveFromParty(battler.index,battler.pokemonIndex)
            battler.pbReset
            battler.participants=[]
          else
            @decision=4
          end
          wasowned = $Trainer.pokedex.dexList[species][:owned?] ### MODDED
          if snag
            pokemon.ot=self.pbPlayer.name
            pokemon.trainerID=self.pbPlayer.id
            $Trainer.pokedex.setOwned(pokemon)
          end
          BallHandlers.onCatch(ball,self,pokemon)
          pokemon.ballused=ball
          pokemon.pbRecordFirstMoves
          if !wasowned ### MODDED
            $Trainer.pokedex.setOwned(pokemon)
            if $Trainer.pokedex.canViewDex && !(@opponent && snag) ### MODDED
              pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pokemon.name))
              @scene.pbShowPokedex(species) 
            end
          end
          @scene.pbHideCaptureBall
          pbGainEXP
          pokemon.form=pokemon.getForm(pokemon)
          if snag && @opponent
            pokemon.pbUpdateShadowMoves rescue nil
            @snaggedpokemon.push(pokemon)
            @scene.partyBetweenKO1
          else
            pbStorePokemon(pokemon)
          end
      end
    end
  end
end