class PokemonOptions
  attr_writer :accessibilityVolume

  def accessibilityVolume
    @accessibilityVolume = 100 unless defined?(@accessibilityVolume) # Volume (0 - 100)
    return @accessibilityVolume
  end

  attr_writer :footstepVolume
  
  def footstepVolume
    @footstepVolume = 100 unless defined?(@footstepVolume) # Volume (0 - 100)
    return @footstepVolume
  end

  attr_writer :eventVolume
  
  def eventVolume
    @eventVolume = 75 unless defined?(@eventVolume) # Volume (0 - 100)
    return @eventVolume
  end

  attr_writer :wallVolume
  
  def wallVolume
    @wallVolume = 100 unless defined?(@wallVolume) # Volume (0 - 100)
    return @wallVolume
  end

  attr_writer :wallRange
  
  def wallRange
    @wallRange = 3 unless defined?(@wallRange) # Ambient SE wall detection range (1 - 6)
    return @wallRange
  end

  attr_writer :ambientRate
  
  def ambientRate
    @ambientRate = 40 unless defined?(@ambientRate) # Ambient SE rate (10 - 200)
    return @ambientRate
  end
end

class << PokemonOptionScene
  alias :crawlioptions_old_new :new

  def new(*args, **kwargs)
    if BlindstepActive
      optionCommands = []
      optionCommands.push(_INTL("General"))
      optionCommands.push(_INTL("Accessibility"))
      option = Kernel.pbMessage(_INTL("What options do you want to see?"), optionCommands)
      if option == 0
        return crawlioptions_old_new(*args, **kwargs)
      else
        return PokemonBlindstepOptionScene.new(*args, **kwargs)
      end
    else
      return crawlioptions_old_new(*args, **kwargs)
    end
  end
end

class PokemonBlindstepOptionScene
  OptionList=[
    NumberOption.new(
      _INTL("Accessibility Volume"), _INTL("Type %d"), 0, 100,
      proc { $Settings.accessibilityVolume },
      proc { |value| $Settings.accessibilityVolume = value },
      "Volume of sound effects for accessibility. Affects all Blindstep sounds."
    ),
    NumberOption.new(
      _INTL("Footstep Volume"), _INTL("Type %d"), 0, 100,
      proc { $Settings.footstepVolume },
      proc { |value| $Settings.footstepVolume = value },
      "Volume of footstep sound effects."
    ),
    NumberOption.new(
      _INTL("Event Volume"), _INTL("Type %d"), 0, 100,
      proc { $Settings.eventVolume },
      proc { |value| $Settings.eventVolume = value },
      "Volume of immediate event sound effects when the player faces it."
    ),
    NumberOption.new(
      _INTL("Wall Volume"), _INTL("Type %d"), 0, 100,
      proc { $Settings.wallVolume },
      proc { |value| $Settings.wallVolume = value },
      "Volume of wall sound effects."
    ),
    NumberOption.new(
      _INTL("Wall Range"), _INTL("Type %d"), 1, 6,
      proc { $Settings.wallRange - 1 },
      proc { |value| $Settings.wallRange = value + 1 },
      "Range of wall detection for wall sound effects."
    ),
    NumberOption.new(
      _INTL("Ambient SE Rate"), _INTL("Type %d"), 10, 200,
      proc { $Settings.ambientRate - 10 },
      proc { |value| $Settings.ambientRate = value + 10 },
      "Rate (in frames) of event and wall sound effects. 40 frames is 1 second."
    )]
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL("Accessibility Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    #@sprites["textbox"].text=_INTL("Speech frame {1}.",1+$Settings.textskin)
    # These are the different options in the game.  To add an option, define a
    # setter and a getter for that option.  To delete an option, comment it out
    # or delete it.  The game's options may be placed in any order.
    @sprites["option"]=Window_PokemonOption.new(OptionList,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport=@viewport
    @sprites["option"].visible=true
    # Get the values of each option
    for i in 0...OptionList.length
      @sprites["option"][i]=(OptionList[i].get || 0)
    end
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbOptions
    pbActivateWindow(@sprites,"option"){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if @sprites["option"].mustUpdateOptions
           # Set the values of each option
           for i in 0...OptionList.length
             OptionList[i].set(@sprites["option"][i])
           end
           @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
           @sprites["textbox"].width=@sprites["textbox"].width  # Necessary evil
           pbSetSystemFont(@sprites["textbox"].contents)
           if @sprites["option"].options[@sprites["option"].index].description.is_a?(Proc)
            @sprites["textbox"].text=@sprites["option"].options[@sprites["option"].index].description.call
           else
            @sprites["textbox"].text=@sprites["option"].options[@sprites["option"].index].description
           end
         end
         if Input.trigger?(Input::B)
          saveClientData
           break
         end
         if Input.trigger?(Input::C) && @sprites["option"].index==OptionList.length
           break
         end
       end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...OptionList.length
      OptionList[i].set(@sprites["option"][i])
    end
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end
