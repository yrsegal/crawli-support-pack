
class PokemonStorageScene

  def pbSelectPartyInternal(party,depositing)
    selection=@selection
    pbPartySetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection,party)
    pbSetMosaic(selection)
    lastsel=1
    lastread = nil ### MODDED
    loop do
      Graphics.update
      Input.update
      key=-1
      ### MODDED/
      if lastread != selection
        if selection == 6 # Close Box
          tts("Back")
        end
        lastread = selection
      end
      ### /MODDED
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE()
        newselection=pbPartyChangeSelection(key,selection)
        if newselection==-1
          return -1 if !depositing
        elsif newselection==-2
          selection=lastsel
        else
          selection=newselection
        end
        pbPartySetArrow(@sprites["arrow"],selection)
        lastsel=selection if selection>0
        pbUpdateOverlay(selection,party)
        pbSetMosaic(selection)
      end
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::A) && @command==0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::C)
        if selection>=0 && selection<6
          @selection=selection
          return selection
        elsif selection==6 # Close Box 
          @selection=selection
          return (depositing) ? -3 : -1
        end
      elsif Input.trigger?(Input::B)
        @selection=selection
        return -1
      end
    end
  end

  def pbUpdateOverlay(selection,party=nil)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    pokemon=nil
    if @screen.pbHeldPokemon
      pokemon=@screen.pbHeldPokemon
    elsif selection>=0
      pokemon=(party) ? party[selection] : @storage[@storage.currentBox,selection]
    end
    if !pokemon
      @sprites["pokemon"].visible=false
      return
    end
    @sprites["pokemon"].visible=true
    speciesname=getMonName(pokemon.species)
    itemname="No item"
    if !pokemon.item.nil?
      itemname=getItemName(pokemon.item)
    end
    abilityname="No ability"
    if !pokemon.ability.nil?
      abilityname=getAbilityName(pokemon.ability)
    end
    base=Color.new(88,88,80)
    shadow=Color.new(168,184,184)
    pokename=pokemon.name
    textstrings=[
       [pokename,10,8,false,base,shadow]
    ]
    if !pokemon.isEgg?
      if pokemon.isMale?
        textstrings.push([_INTL("♂"),148,8,false,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pokemon.isFemale?
        textstrings.push([_INTL("♀"),148,8,false,Color.new(248,56,32),Color.new(224,152,144)])
      end
      textstrings.push([_INTL("{1}",pokemon.level),36,234,false,base,shadow])
      textstrings.push([_INTL("{1}",abilityname),85,306,2,base,shadow])
      textstrings.push([_INTL("{1}",itemname),85,342,2,base,shadow])
    end
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay,textstrings)
    textstrings.clear
    if !pokemon.isEgg?
      textstrings.push([_INTL("Lv."),10,242,false,base,shadow])
    end
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay,textstrings)
    if !pokemon.isEgg?
      if pokemon.isShiny?
        imagepos=[(["Graphics/Pictures/shiny",156,198,0,0,-1,-1])]
        pbDrawImagePositions(overlay,imagepos)
      end
      typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      imagepos=[]
      if pokemon.type2.nil?
        imagepos.push([sprintf("Graphics/Icons/type%s",pokemon.type1),52,272,0,0,64,28])
      else
        imagepos.push([sprintf("Graphics/Icons/type%s",pokemon.type1),18,272,0,0,64,28])
        imagepos.push([sprintf("Graphics/Icons/type%s",pokemon.type2),88,272,0,0,64,28])
      end
      pbDrawImagePositions(overlay,imagepos)
      #type1rect=Rect.new(0,pokemon.type1*28,64,28)
      # type2rect=Rect.new(0,pokemon.type2*28,64,28)
      # if pokemon.type1==pokemon.type2
      #   overlay.blt(52,272,typebitmap.bitmap,type1rect)
      # else
      #   overlay.blt(18,272,typebitmap.bitmap,type1rect)
      #   overlay.blt(88,272,typebitmap.bitmap,type2rect)
      # end
    end
    drawMarkings(overlay,66,240,128,20,pokemon.markings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)
    if pokemon.species == :EXEGGUTOR && pokemon.form == 1
      pbPositionPokemonSprite(@sprites["pokemon"],26,70-97)
    else      
      pbPositionPokemonSprite(@sprites["pokemon"],26,64)
    end    
    tts(pbPokemonString(pokemon)) ### MODDED
  end


  def pbSelectBoxInternal(party)
    selection=@selection
    pbSetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    lastread = selection ### MODDED
    loop do
      Graphics.update
      Input.update
      ### MODDED/
      if lastread != selection
        if selection == -1 # Box name
          tts(@storage[@storage.currentBox].name)
        elsif selection == -2 # Party Pokémon
          tts("Party Pokémon")
        elsif selection == -3 # Close Box
          tts("Close box")
        end
        lastread = selection
      end
      ### /MODDED
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE()
        selection=pbChangeSelection(key,selection)
        pbSetArrow(@sprites["arrow"],selection)
        nextbox=-1
        if selection==-4
          nextbox=(@storage.currentBox==0) ? @storage.maxBoxes-1 : @storage.currentBox-1
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox=nextbox
          tts(@storage[@storage.currentBox].name) ### MODDED
          selection=-1
        elsif selection==-5
          nextbox=(@storage.currentBox==@storage.maxBoxes-1) ? 0 : @storage.currentBox+1
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox=nextbox
          tts(@storage[@storage.currentBox].name) ### MODDED
          selection=-1
        end
        selection=-1 if selection==-4 || selection==-5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      end
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::A) && @command==0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::C)
        if selection>=0
          @selection=selection
          return [@storage.currentBox,selection]
        elsif selection==-1 # Box name 
          @selection=selection
          return [-4,-1]
        elsif selection==-2 # Party Pokémon 
          @selection=selection
          return [-2,-1]
        elsif selection==-3 # Close Box 
          @selection=selection
          return [-3,-1]
        end
      end
      if Input.trigger?(Input::B)
        @selection=selection
        return nil
      end
    end
  end

  alias :crawlittsstorage_old_pbShowCommands :pbShowCommands
  
  def pbShowCommands(message,commands,index=0)
    tts(message)
    return crawlittsstorage_old_pbShowCommands(message,commands,index)
  end

  alias :crawlittsstorage_old_pbDisplay :pbDisplay

  def pbDisplay(message)
    tts(message)
    return crawlittsstorage_old_pbDisplay(message)
  end
end
