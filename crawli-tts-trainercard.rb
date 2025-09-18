class PokemonTrainerCardScene
  def pbDrawTrainerCardFront
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time=_ISPRINTF("{1:02d}:{2:02d}",hour,min)
    $PokemonGlobal.startTime=pbGetTimeNow if !$PokemonGlobal.startTime
    starttime=_ISPRINTF("{1:s} {2:d}, {3:d}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    pubid=sprintf("%05d",$Trainer.publicID($Trainer.id))
    baseColor=Color.new(210,215,220) # Updated
    shadowColor=Color.new(70,75,80) # Updated
    ownedCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getOwnedCount
    seenCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getSeenCount
    money = $game_switches[:NotPlayerCharacter] ? "???" : "$#{$Trainer.money}"
    textPositions=[
       [_INTL("Name"),34,64,0,baseColor,shadowColor],
       [_INTL("{1}",$Trainer.name),302,64,1,baseColor,shadowColor],
       [_INTL("ID No."),332,64,0,baseColor,shadowColor],
       [_INTL("{1}",pubid),468,64,1,baseColor,shadowColor],
       [_INTL("Money"),34,112,0,baseColor,shadowColor],
       [_INTL("{1}",money),302,112,1,baseColor,shadowColor],
       [_INTL("Pokédex"),34,160,0,baseColor,shadowColor],
       [_INTL("{1}/{2}",ownedCount,seenCount),302,160,1,baseColor,shadowColor],
       [_INTL("Time"),34,208,0,baseColor,shadowColor],
       
 # UPDATE- Adding room for 18 badges      
       [time,302,208,1,baseColor,shadowColor]
     #  [_INTL("Started"),34,256,0,baseColor,shadowColor],
      # [starttime,302,256,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    return if $game_switches[:NotPlayerCharacter]
    y=262
    imagePositions=[]
    if Desolation
      x=80
      for i in 0...7
        if $Trainer.badges[i]
          imagePositions.push( ["Graphics/Pictures/badges",x,y,i*48,0,48,48])
        end
        x+=50
      end
      y+=50
      x=130
      for i in 0...5
        if $Trainer.badges[i+7]
          imagePositions.push( ["Graphics/Pictures/badges",x,y,i*48,48,48,48])
        end
        x+=50
      end
    else
      for region in 0...2 # Two rows
        x=32
        for i in 0...9
          if $Trainer.badges[i+region*9]
            if Rejuv && ($game_variables[:V13Story]>=11)
              imagePositions.push( ["Graphics/Pictures/badges_1",x,y,i*48,region*48,48,48])
            else
              imagePositions.push( ["Graphics/Pictures/badges",x,y,i*48,region*48,48,48])
            end
          end
          x+=50
        end
        y+=50
      end
    end
    ### MODDED/
    tts("Trainer Card")
    tts(sprintf("Name: %s", $Trainer.name))
    tts(sprintf("ID Number: %s", pubid))
    tts(sprintf("Money: %s", money))
    tts(sprintf("Pokédex: %s seen, %s caught", seenCount, ownedCount))
    tts(sprintf("Time: %s hours and %s minutes", hour, min))
    tts(sprintf("Badges: %d", $Trainer.numbadges))
    tts(sprintf("Level Cap: %d", [LEVELCAPS[$Trainer.numbadges], 100 + $game_variables[:Extended_Max_Level]].min))
    ### /MODDED
    pbDrawImagePositions(overlay,imagePositions)
  end
end
