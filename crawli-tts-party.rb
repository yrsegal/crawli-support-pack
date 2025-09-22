
module UIHelper
  def self.pbChooseNumber(helpwindow,helptext,maximum)
    oldvisible=helpwindow.visible
    helpwindow.visible=true
    helpwindow.text=helptext
    helpwindow.letterbyletter=false
    curnumber=1
    ret=0
    using_block(numwindow=Window_UnformattedTextPokemon.new("x000")){
       numwindow.viewport=helpwindow.viewport
       numwindow.letterbyletter=false
       numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
       numwindow.resizeToFit(numwindow.text,480)
       pbBottomRight(numwindow) # Move number window to the bottom right
       helpwindow.resizeHeightToFit(helpwindow.text,480-numwindow.width)
       pbBottomLeft(helpwindow) # Move help window to the bottom left
       tts(helptext) ### MODDED
       loop do
         Graphics.update
         Input.update
         numwindow.update
         block_given? ? yield : helpwindow.update
         if Input.repeat?(Input::LEFT)
           curnumber-=10
           curnumber=1 if curnumber<1
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           tts(curnumber.to_s) ### MODDED
           pbPlayCursorSE()
         elsif Input.repeat?(Input::RIGHT)
           curnumber+=10
           curnumber=maximum if curnumber>maximum
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           tts(curnumber.to_s) ### MODDED
           pbPlayCursorSE()
         elsif Input.repeat?(Input::UP)
           curnumber+=1
           curnumber=1 if curnumber>maximum
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           tts(curnumber.to_s) ### MODDED
           pbPlayCursorSE()
         elsif Input.repeat?(Input::DOWN)
           curnumber-=1
           curnumber=maximum if curnumber<1
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           tts(curnumber.to_s) ### MODDED
           pbPlayCursorSE()
         elsif Input.trigger?(Input::C)
           ret=curnumber
           pbPlayDecisionSE()
           break
         elsif Input.trigger?(Input::B)
           ret=0
           pbPlayCancelSE()
           break
         end
       end
    }
    helpwindow.visible=oldvisible
    return ret
  end

  def self.pbDisplayStatic(msgwindow,message)
    oldvisible=msgwindow.visible
    msgwindow.visible=true
    msgwindow.letterbyletter=false
    msgwindow.width=Graphics.width
    msgwindow.resizeHeightToFit(message,Graphics.width)
    msgwindow.text=message
    pbBottomRight(msgwindow)
    tts(message) ### MODDED
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::C)
        break
      end
      block_given? ? yield : msgwindow.update
    end
    msgwindow.visible=oldvisible
    Input.update
  end

  # Letter by letter display of the message _msg_ by the window _helpwindow_.
  def self.pbDisplay(helpwindow,msg,brief)
    cw=helpwindow
    cw.letterbyletter=true
    cw.text=msg+"\1"
    pbBottomLeftLines(cw,2)
    oldvisible=cw.visible
    cw.visible=true
    tts(msg) ### MODDED
    loop do
      Graphics.update
      Input.update
      block_given? ? yield : cw.update
      if brief && !cw.busy?
        cw.visible=oldvisible
        return
      end
      if Input.trigger?(Input::C) && cw.resume && !cw.busy?
        cw.visible=oldvisible
        return
      end
    end
  end

  # Letter by letter display of the message _msg_ by the window _helpwindow_,
  # used to ask questions.  Returns true if the user chose yes, false if no.
  def self.pbConfirm(helpwindow,msg)
    dw=helpwindow
    oldvisible=dw.visible
    dw.letterbyletter=true
    dw.text=msg
    dw.visible=true
    pbBottomLeftLines(dw,2)
    commands=[_INTL("Yes"),_INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport=helpwindow.viewport
    pbBottomRight(cw)
    cw.y-=dw.height
    cw.index=0
    tts(msg) ### MODDED
    loop do
      cw.visible=!dw.busy?
      Graphics.update
      Input.update
      cw.update
      block_given? ? yield : dw.update
      if Input.trigger?(Input::B) && dw.resume && !dw.busy?
        cw.dispose
        dw.visible=oldvisible
        pbPlayCancelSE()
        return false
      end
      if Input.trigger?(Input::C) && dw.resume && !dw.busy?
        cwIndex=cw.index
        cw.dispose
        dw.visible=oldvisible
        pbPlayDecisionSE()
        return (cwIndex==0)? true:false
      end
    end
  end

  def self.pbShowCommands(helpwindow,helptext,commands)
    ret=-1
    oldvisible=helpwindow.visible
    helpwindow.visible=helptext ? true : false
    helpwindow.letterbyletter=false
    helpwindow.text=helptext ? helptext : ""
    cmdwindow=Window_CommandPokemon.new(commands)
    tts(commands[cmdwindow.index]) ### MODDED
    begin
      cmdwindow.viewport=helpwindow.viewport
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helpwindow.text,480-cmdwindow.width)
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        yield
        cmdwindow.update
        if Input.trigger?(Input::B)
          ret=-1
          pbPlayCancelSE()
          break
        end
        if Input.trigger?(Input::C)
          ret=cmdwindow.index
          pbPlayDecisionSE()
          break
        end
      end
      ensure
      cmdwindow.dispose if cmdwindow
    end
    helpwindow.visible=oldvisible
    return ret
  end
end

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

  alias :crawlittsparty_old_pbDisplay :pbDisplay

  def pbDisplay(text)
    tts(text)
    return crawlittsparty_old_pbDisplay(text)
  end

  alias :crawlittsparty_old_pbDisplayConfirm :pbDisplayConfirm

  def pbDisplayConfirm(text)
    tts(text)
    return crawlittsparty_old_pbDisplayConfirm(text)
  end
  
  alias :crawlittsparty_old_pbConfirm :pbConfirm

  def pbConfirm(text)
    tts(text)
    return crawlittsparty_old_pbConfirm(text)
  end
end
