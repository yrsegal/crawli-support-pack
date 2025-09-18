class PokemonOptionScene

  def pbOptions
    pbActivateWindow(@sprites,"option"){
      ### MODDED/
      lastread = nil
      if @sprites["option"].options
        opt = @sprites["option"].options[0]
        tts(opt.name)
        opt.current(@sprites["option"][0])
        lastread = opt.name
      end
      ### /MODDED
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
           ### MODDED/
           if opt.name != lastread
             tts(opt.name)
             opt.current(@sprites["option"][@sprites["option"].index])
             tts(@sprites["textbox"].text)
             lastread = opt.name
           end
           ### /MODDED
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
end

class EnumOption
  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    tts(@values[index]) ### MODDED
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    tts(@values[index]) ### MODDED
    return index
  end

  def current(index)
    tts(@values[index])
  end
end

class NumberOption
  def next(current)
    index=current+@optstart
    index+=1
    if index>@optend
      index=@optstart
    end
    tts(index.to_s) ### MODDED
    return index-@optstart
  end

  def prev(current)
    index=current+@optstart
    index-=1
    if index<@optstart
      index=@optend
    end
    tts(index.to_s) ### MODDED
    return index-@optstart
  end

  def current(index)
    tts((index + @optstart).to_s)
  end
end