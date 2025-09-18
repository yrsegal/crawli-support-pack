
class PokemonScreen_Scene
  alias :crawlittsparty_old_pbShowCommands :pbShowCommands

  def pbShowCommands(helptext,commands,index=0)
    tts(helptext)
    return crawlittsparty_old_pbShowCommands(helptext,commands,index)
  end

  def pbSetHelpText(helptext)
    helpwindow=@sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    tts(helptext) if helpwindow.text != helptext ### MODDED
    helpwindow.text=helptext
    helpwindow.width=398
    helpwindow.visible=true
  end

  def pbChoosePokemon(switching=false,allow_party_switch=false,canswitch=0)
    for i in 0...6
      @sprites["pokemon#{i}"].preselected=(switching&&i==@activecmd)
      @sprites["pokemon#{i}"].switching=switching
    end
    pbRefresh
    ### MODDED/
    lastread = nil
    if @activecmd == 6 && @multiselect
      tts('Confirm')
    elsif @activecmd >= 6
      tts('Cancel')
    else
      tts(pbPokemonString(@sprites["pokemon#{@activecmd}"].pokemon))
    end
    ### /MODDED
    loop do
      Graphics.update
      Input.update
      self.update
      oldsel=@activecmd
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key>=0
        @activecmd=pbChangeSelection(key,@activecmd)
      end
      if @activecmd!=oldsel # Changing selection
        pbPlayCursorSE()
        numsprites=(@multiselect) ? 8 : 7
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected=(i==@activecmd)
        end
        ### MODDED/
        if @activecmd == 6 && @multiselect
          tts('Confirm')
        elsif @activecmd >= 6
          tts('Cancel')
        else
          tts(pbPokemonString(@sprites["pokemon#{@activecmd}"].pokemon))
        end
        ### /MODDED
      end
      if allow_party_switch && canswitch==0 && Input.trigger?(Input::X)
        return [1,@activecmd]
      elsif allow_party_switch && Input.trigger?(Input::X) && canswitch==1
        return @activecmd
      end
      if Input.trigger?(Input::B)
        return -1
      end
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        cancelsprite=(@multiselect) ? 7 : 6
        return (@activecmd==cancelsprite) ? -1 : @activecmd
      end
    end
  end

  def pbDisplay(text)
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    tts(text) ### MODDED
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update
      if @sprites["messagebox"].busy? && Input.trigger?(Input::C)
        pbPlayDecisionSE() if @sprites["messagebox"].pausing?
        @sprites["messagebox"].resume
      end
      if !@sprites["messagebox"].busy? &&
         (Input.trigger?(Input::C) || Input.trigger?(Input::B))
        break
      end
    end
    @sprites["messagebox"].visible=false
    @sprites["helpwindow"].visible=true
  end

  def pbDisplayConfirm(text)
    ret=-1
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    tts(text) ### MODDED
    using_block(cmdwindow=Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])){
       cmdwindow.z=@viewport.z+1
       cmdwindow.visible=false
       pbBottomRight(cmdwindow)
       cmdwindow.y-=@sprites["messagebox"].height
       loop do
         Graphics.update
         Input.update
         cmdwindow.visible=true if !@sprites["messagebox"].busy?
         cmdwindow.update
         self.update
         if Input.trigger?(Input::B) && !@sprites["messagebox"].busy?
           ret=false
           break
         end
         if Input.trigger?(Input::C) && @sprites["messagebox"].resume && !@sprites["messagebox"].busy?
           ret=(cmdwindow.index==0)
           break
         end
       end
    }
    @sprites["messagebox"].visible=false
    @sprites["helpwindow"].visible=true
    return ret
  end
  
  def pbConfirm(text)
    ret=-1
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    tts(text) ### MODDED
    using_block(cmdwindow=Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])){
      cmdwindow.z=@viewport.z+1
      cmdwindow.visible=false
      pbBottomRight(cmdwindow)
      cmdwindow.y-=@sprites["messagebox"].height
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible=true if !@sprites["messagebox"].busy?
        cmdwindow.update
        self.update
        if Input.trigger?(Input::B) && !@sprites["messagebox"].busy?
          ret=false
          break
        end
        if Input.trigger?(Input::C) && @sprites["messagebox"].resume && !@sprites["messagebox"].busy?
          ret=(cmdwindow.index==0)
          break
        end
      end
    }
    @sprites["messagebox"].visible=false
    @sprites["helpwindow"].visible=true
    return ret
  end
end
