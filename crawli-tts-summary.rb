class PokemonSummaryScene

  def pbChooseMoveToForget(moveToLearn)
    selmove=0
    ret=0
    maxmove=(moveToLearn!=0) ? 4 : 3
    ### MODDED/
    lastread = nil
    ### /MODDED
    loop do
      Graphics.update
      Input.update
      pbUpdate
      ### MODDED/
      if lastread != selmove
        if selmove == 4
          readobj = PBMove.new(moveToLearn) if moveToLearn != 0
        else
          readobj = @pokemon.moves[selmove]
        end
        reading = (selmove == 4) ? moveToLearn : @pokemon.moves[selmove].move
        tts(moveToString(reading, readobj))
        lastread = selmove
      end
      ### /MODDED
      if Input.trigger?(Input::B)
        ret=4
        break
      end
      if Input.trigger?(Input::C)
        break
      end
      if Input.trigger?(Input::DOWN)
        selmove+=1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=(moveToLearn>0) ? maxmove : 0
        end
        selmove=0 if selmove>maxmove
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].move
        drawSelectedMove(@pokemon,moveToLearn,newmove)
        ret=selmove
      end
      if Input.trigger?(Input::UP)
        selmove-=1
        selmove=maxmove if selmove<0
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=@pokemon.numMoves-1
        end
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].move
        drawSelectedMove(@pokemon,moveToLearn,newmove)
        ret=selmove
      end
    end
    return (ret==4) ? -1 : ret
  end
end
