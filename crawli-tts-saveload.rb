class PokemonLoadScene

  def pbDrawSaveCommands(savefiles)
    @savefiles = savefiles
    @sprites["overlay"].bitmap.clear
    textpos = []
    if savefiles.length >= 9
      numsavebuttons = 9
    else
      numsavebuttons = savefiles.length
    end
    for i in 0...numsavebuttons
      @sprites["savefile#{i}"] = IconSprite.new(Graphics.width / 2 - 384 / 2, i * 45, @viewport)
      @sprites["savefile#{i}"].setBitmap("Graphics/Pictures/loadsavepanel")
      @sprites["savefile#{i}"].zoom_x = 0.5
      @sprites["savefile#{i}"].zoom_y = 0.5
      Graphics.update
      loop do
        @sprites["savefile#{i}"].zoom_x += 0.5
        @sprites["savefile#{i}"].zoom_y += 0.5
        Graphics.update
        break if @sprites["savefile#{i}"].zoom_x == 1
      end
      if i < 10
        if savefiles[i][1].start_with?("Anna's Wish")
          textpos.push([savefiles[i][1], Graphics.width / 2 - savefiles[i][1].length * 4.5, i * 45 + 12, 0, Color.new(218, 182, 214), Color.new(139, 131, 148)])
        else
          textpos.push([savefiles[i][1], Graphics.width / 2 - savefiles[i][1].length * 4.5, i * 45 + 12, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
        end
        pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
      end
    end
    pbDrawSaveText(savefiles)
    @sprites["saveselect"] = IconSprite.new(Graphics.width / 2 - 384 / 2, 0, @viewport)
    @sprites["saveselect"].setBitmap("Graphics/Pictures/loadsavepanel_1")
    Graphics.update
    pbToggleSelecting
    tts(@savefiles[0][1]) ### MODDED
  end

  def pbMoveSaveSel(index)
    tts(@savefiles[index][1]) ### MODDED
    @index = index
    if index <= 7
      @sprites["saveselect"].y = index * 45
      pbDrawSaveText(@savefiles)
    elsif index == @savefiles.length - 1
      @sprites["saveselect"].y = 7 * 45
      pbDrawSaveText(@savefiles, 0, 45 * (index - 7))
    else
      pbDrawSaveText(@savefiles, 0, 45 * (index - 7))
    end
    if index == (@savefiles.length - 1) && @savefiles.length - 1 >= 8
      @sprites["savefile8"].visible = false if @sprites["savefile8"]
    else
      @sprites["savefile8"].visible = true if @sprites["savefile8"]
    end
    Graphics.update
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    lastread = nil ### MODDED
    loop do
      Graphics.update
      Input.update
      tts(commands[@sprites["cmdwindow"].index]) if @sprites["cmdwindow"].index != lastread  ### MODDED
      lastread = @sprites["cmdwindow"].index  ### MODDED
      pbUpdate
      if Input.trigger?(Input::C) && (!@saveselecting || @saveselecting == false)
        return @sprites["cmdwindow"].index
      end
    end
  end
end

class PokemonSaveScene
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname=$game_map.name
    textColor="0070F8,78B8E8"
    loctext=_INTL("<ac><c2=06644bd2>{1}</c2></ac>",mapname)
    tts(mapname) ### MODDED
    loctext+=_INTL("Player<r><c3={1}>{2}</c3><br>",textColor,$Trainer.name)
    tts($Trainer.name) ### MODDED
    loctext+=_ISPRINTF("Time<r><c3={1:s}>{2:02d}:{3:02d}</c3><br>",textColor,hour,min)
    loctext+=_INTL("Badges<r><c3={1}>{2}</c3><br>",textColor,$Trainer.numbadges)
    tts("#{$Trainer.numbadges} badges") ### MODDED
    if $Trainer.pokedex.canViewDex
      loctext+=_INTL("Pokédex<r><c3={1}>{2}/{3}</c3><br>",textColor,$Trainer.pokedex.getOwnedCount,$Trainer.pokedex.getSeenCount)
      tts("Pokédex: owned #{$Trainer.pokedex.getOwnedCount} / seen #{$Trainer.pokedex.getSeenCount}") ### MODDED
    end
    if $Unidata[:saveslot]>1
      loctext+=_INTL("Save File:<r><c3={1}>{2}</c3><br>",textColor,$Unidata[:saveslot])
      tts("Save File: #{$Unidata[:saveslot]}") ### MODDED
    else
      loctext+=_INTL("Save File:<r><c3={1}>1</c3><br>",textColor)
      tts("Save File: 1") ### MODDED
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=0
    @sprites["locwindow"].width=228 if @sprites["locwindow"].width<228
    @sprites["locwindow"].visible=true
  end
end
