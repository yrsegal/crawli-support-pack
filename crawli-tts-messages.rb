def Kernel.pbShowCommandsWithHelp(msgwindow,commands,help,cmdIfCancel=0,defaultCmd=0)
  msgwin=msgwindow
  if !msgwindow
    msgwin=Kernel.pbCreateMessageWindow(nil)
  end
  oldlbl=msgwin.letterbyletter
  msgwin.letterbyletter=false
  if commands
    cmdwindow=Window_CommandPokemon.new(commands, tts: false)
    cmdwindow.z=99999
    cmdwindow.visible=true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height=msgwin.y if cmdwindow.height>msgwin.y
    cmdwindow.index=defaultCmd
    command=0
    msgwin.text=help[cmdwindow.index]
    msgwin.width=msgwin.width # Necessary evil to make it use the proper margins.
    ### MODDED/
    tts(commands[cmdwindow.index])
    tts(help[cmdwindow.index])
    ### /MODDED
    loop do
      Graphics.update
      Input.update
      oldindex=cmdwindow.index
      cmdwindow.update
      if oldindex!=cmdwindow.index
        msgwin.text=help[cmdwindow.index]
        ### MODDED/
        tts(commands[cmdwindow.index])
        tts(help[cmdwindow.index])
        ### /MODDED
      end
      msgwin.update
      yield if block_given?
      if Input.trigger?(Input::B)
        if cmdIfCancel>0
          command=cmdIfCancel-1
          pbWait(2)
          break
        elsif cmdIfCancel<0
          command=cmdIfCancel
          pbWait(2)
          break
        end
      end
      if Input.trigger?(Input::C)
        command=cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret=command
    cmdwindow.dispose
    Input.update
  end
  msgwin.letterbyletter=oldlbl
  if !msgwindow
    msgwin.dispose
  end
  return ret
end

class Interpreter
  attr_reader :message_waiting
end

def Kernel.pbShowCommands(msgwindow,commands=nil,cmdIfCancel=0,defaultCmd=0)
  ret=0
  if commands
    interp = pbMapInterpreter
    pbSEPlay("navopen", 100, 120) if msgwindow || (interp && interp.message_waiting)
    cmdwindow=Window_CommandPokemon.new(commands)
    cmdwindow.z=99999
    cmdwindow.visible=true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow,msgwindow,:right)
    cmdwindow.index=defaultCmd
    command=0
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      msgwindow.update if msgwindow
      yield if block_given?
      if Input.trigger?(Input::B)
        if cmdIfCancel>0
          command=cmdIfCancel-1
          pbWait(2)
          break
        elsif cmdIfCancel<0
          command=cmdIfCancel
          pbWait(2)
          break
        end
      end
      if Input.trigger?(Input::C)
        command=cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret=command
    cmdwindow.dispose
    Input.update
  end
  return ret
end

def Kernel.pbMessageDisplay(msgwindow,message,letterbyletter=true,commandProc=nil)
  return if !msgwindow
  oldletterbyletter=msgwindow.letterbyletter
  msgwindow.letterbyletter=(letterbyletter ? true : false)
  ret=nil
  count=0
  commands=nil
  facewindow=nil
  goldwindow=nil
  coinwindow=nil
  apwindow=nil
  cmdvariable=0
  cmdIfCancel=0
  msgwindow.waitcount=0
  autoresume=false
  text=message.clone
  msgback=nil
  linecount=(Graphics.height>400) ? 3 : 2
  ### Text replacement
  if Rejuv
    if $game_switches && $game_switches[:AtebitDesire]
      text.insert(0,"\\gsc")
      text.insert(-1,"\\egsc")
      msgwindow.setSkin("Graphics/Windowskins/speech hgss 34")
    end
    text.gsub!(/\\[Gg][Ss][Cc]/,"<fn=PKMN RBYGSC><fs=22>")
    text.gsub!(/\\[Ee][Gg][Ss][Cc]/,"</fs></fn>")
  end
  text.gsub!(/\\\\/,"\5")
  if $game_actors
    text.gsub!(/\\[Nn]\[([1-8])\]/){ 
       m=$1.to_i
       next $game_actors[m].name
    }
  end
  text.gsub!(/\\[Ss][Ii][Gg][Nn]\[([^\]]*)\]/){ 
     next "\\op\\cl\\ts[]\\w["+$1+"]"
  }
  text.gsub!(/\\[Pp][Nn]Upper/,$Trainer.name.upcase) if $Trainer
  text.gsub!(/\\[Pp][Nn]Lower/,$Trainer.name.downcase) if $Trainer
  text.gsub!(/\\[Pp][Nn]/,$Trainer.name) if $Trainer
  text.gsub!(/\\[Pp][Mm]/,_INTL("${1}",pbCommaNumber($Trainer.money))) if $Trainer
  text.gsub!(/\\[Nn]/,"\n")
  text.gsub!(/\\\[([0-9A-Fa-f]{8,8})\]/){ "<c2="+$1+">" }
  text.gsub!(/\\[Pp][Gg]/,"\\b") if $Trainer && $Trainer.isMale?
  text.gsub!(/\\[Pp][Gg]/,"\\r") if $Trainer && $Trainer.isFemale?
  text.gsub!(/\\[Pp][Oo][Gg]/,"\\r") if $Trainer && $Trainer.isMale?
  text.gsub!(/\\[Pp][Oo][Gg]/,"\\b") if $Trainer && $Trainer.isFemale?
  text.gsub!(/\\[Pp][Gg]/,"")
  text.gsub!(/\\[Pp][Oo][Gg]/,"")
  text.gsub!(/\\[Bb]/,"<c2=6546675A>")
  text.gsub!(/\\[Rr]/,"<c2=043C675A>")
  text.gsub!(/\\1/,"\1")
  colortag=""
  isDarkSkin=isDarkWindowskin(msgwindow.windowskin)
  if ($game_message && $game_message.background>0) ||
     ($game_system && $game_system.respond_to?("message_frame") &&
      $game_system.message_frame != 0)
    colortag=getSkinColor(msgwindow.windowskin,0,true)
  else
    colortag=getSkinColor(msgwindow.windowskin,0,isDarkSkin)
  end
  text.gsub!(/\\[Cc]\[([0-9]+)\]/){ 
     m=$1.to_i
     next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
  }
  begin
    last_text = text.clone
    text.gsub!(/\\[Vv][Uu]\[([0-9]+)\]/) { $game_variables[$1.to_i].upcase }
    text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
  rescue
    text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
  end until text == last_text
  begin
    last_text = text.clone
    text.gsub!(/\\[Ll]\[([0-9]+)\]/) { 
       linecount=[1,$1.to_i].max;
       next "" 
    }
  end until text == last_text
  text=colortag+text
  ### Controls
  textchunks=[]
  controls=[]
  while text[/(?:\\([WwFf]|[Ff][Ff]|[Tt][Ss]|[Cc][Ll]|[Mm][Ee]|[Ss][Ee]|[Ww][Tt]|[Ww][Tt][Nn][Pp]|[Cc][Hh])\[([^\]]*)\]|\\([Gg]|[Cc][Nn]|[Aa][Pp]|[Ww][Dd]|[Ww][Mm]|[Oo][Pp]|[Ss][Hh]|[Cc][Ll]|[Ww][Uu]|[\.]|[\|]|[\!]|[\x5E])())/i]
    textchunks.push($~.pre_match)
    if $~[1]
      controls.push([$~[1].downcase,$~[2],-1])
    else
      controls.push([$~[3].downcase,"",-1])
    end
    text=$~.post_match
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/\005/,"\\")
  end
  textlen=0
  for i in 0...controls.length
    control=controls[i][0]
    if control=="wt" || control=="wtnp" || control=="." || control=="|"
      textchunks[i]+="\2"
    elsif control=="!"
      textchunks[i]+="\1"
    end
    textlen+=toUnformattedText(textchunks[i]).scan(/./m).length
    controls[i][2]=textlen
  end
  text=textchunks.join("")
  unformattedText=toUnformattedText(text)
  tts(unformattedText) ### MODDED
  signWaitCount=0
  shout = false
  haveSpecialClose=false
  specialCloseSE=""
  for i in 0...controls.length
    control=controls[i][0]
    param=controls[i][1]
    if control=="f"
      facewindow.dispose if facewindow
      facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
    elsif control=="op"
      signWaitCount=21
    elsif control=="sh"
      shout=true
      signWaitCount=16
      startSE="shout"
      msgwindow.setSkin("Graphics/Windowskins/shout")
      msgwindow.width=msgwindow.width  # Necessary evil
    elsif control=="cl"
      text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
      haveSpecialClose=true
      specialCloseSE=param
    elsif control=="se" && controls[i][2]==0
      startSE=param
      controls[i]=nil
    elsif control=="ff"
      facewindow.dispose if facewindow
      facewindow=FaceWindowVX.new(param)
    elsif control=="ch"
      cmds=param.clone
      cmdvariable=pbCsvPosInt!(cmds)
      cmdIfCancel=pbCsvField!(cmds).to_i
      commands=[]
      while cmds.length>0
        commands.push(pbCsvField!(cmds))
      end
    elsif control=="wtnp" || control=="^"
      text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
    end
  end
  if startSE!=nil
    pbSEPlay(pbStringToAudioFile(startSE))
  elsif signWaitCount==0 && letterbyletter
    pbPlayDecisionSE()
  end
  ########## Position message window  ##############
  pbRepositionMessageWindow(msgwindow,linecount)
  if $game_message && $game_message.background==1
    msgback=IconSprite.new(0,msgwindow.y,msgwindow.viewport)
    msgback.z=msgwindow.z-1
    msgback.setBitmap("Graphics/System/MessageBack")
  end
  if facewindow
    pbPositionNearMsgWindow(facewindow,msgwindow,:left)
    facewindow.viewport=msgwindow.viewport
    facewindow.z=msgwindow.z
  end
  atTop=(msgwindow.y==0)
  ########## Show text #############################
  msgwindow.text=text
  Graphics.frame_reset if Graphics.frame_rate>40
  begin
    if signWaitCount != 0 && shout
      signWaitCount=(signWaitCount*-0.9).floor
      if atTop
        msgwindow.y=signWaitCount
      else
        msgwindow.y=Graphics.height-(msgwindow.height + signWaitCount)
      end
    elsif signWaitCount>0
      signWaitCount-=1
      if atTop
        msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
      else
        msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
      end
    end
    for i in 0...controls.length
      if controls[i] && controls[i][2]<=msgwindow.position && msgwindow.waitcount==0
        control=controls[i][0]
        param=controls[i][1]
        if control=="f"
          facewindow.dispose if facewindow
          facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          facewindow.viewport=msgwindow.viewport
          facewindow.z=msgwindow.z
        elsif control=="ts"
          if param==""
            msgwindow.textspeed=-999
          else
            msgwindow.textspeed=param.to_i
          end
        elsif control=="ff"
          facewindow.dispose if facewindow
          facewindow=FaceWindowVX.new(param)
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          facewindow.viewport=msgwindow.viewport
          facewindow.z=msgwindow.z
        elsif control=="g" # Display gold window
          goldwindow.dispose if goldwindow
          goldwindow=pbDisplayGoldWindow(msgwindow)
        elsif control=="cn" # Display coins window
          coinwindow.dispose if coinwindow
          coinwindow=pbDisplayCoinsWindow(msgwindow,goldwindow)
        elsif control=="ap" # Display coins window
          apwindow.dispose if apwindow
          apwindow=pbDisplayAPWindow(msgwindow,goldwindow)
        elsif control=="wu"
          msgwindow.y=0
          atTop=true
          msgback.y=msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
        elsif control=="wm"
          atTop=false
          msgwindow.y=(Graphics.height/2)-(msgwindow.height/2)
          msgback.y=msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        elsif control=="wd"
          atTop=false
          msgwindow.y=(Graphics.height)-(msgwindow.height)
          msgback.y=msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
        elsif control=="."
          msgwindow.waitcount+=Graphics.frame_rate/4
        elsif control=="|"
          msgwindow.waitcount+=Graphics.frame_rate
        elsif control=="wt" # Wait
          param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
          msgwindow.waitcount+=param.to_i*2
        elsif control=="w" # Windowskin
          if param==""
            msgwindow.windowskin=nil
          else
            msgwindow.setSkin("Graphics/Windowskins/#{param}")
          end
          msgwindow.width=msgwindow.width  # Necessary evil
        elsif control=="^" # Wait, no pause
          autoresume=true
        elsif control=="wtnp" # Wait, no pause
          param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
          msgwindow.waitcount=param.to_i*2
          autoresume=true
        elsif control=="se" # Play SE
          pbSEPlay(pbStringToAudioFile(param))
        elsif control=="me" # Play ME
          pbMEPlay(pbStringToAudioFile(param))
        end
        controls[i]=nil
      end
    end
    break if !letterbyletter
    Graphics.update
    Input.update
    facewindow.update if facewindow
    if autoresume && msgwindow.waitcount==0
      msgwindow.resume if msgwindow.busy?
      break if !msgwindow.busy?
    end
    if Input.press?(Input::B)
      msgwindow.textspeed=-999
      msgwindow.update
      if msgwindow.busy?
        pbPlayDecisionSE() if msgwindow.pausing?
        msgwindow.resume
      else
        break if signWaitCount==0
      end
      end
    if (Input.trigger?(Input::C) || Input.trigger?(Input::B))
      if msgwindow.busy?
        pbPlayDecisionSE() if msgwindow.pausing?
        msgwindow.resume
      else
        break if signWaitCount==0
      end
    end
    pbUpdateSceneMap
    msgwindow.update
    yield if block_given?
  end until (!letterbyletter || commandProc || commands) && !msgwindow.busy?
  Input.update # Must call Input.update again to avoid extra triggers
  msgwindow.letterbyletter=oldletterbyletter
  if commands
    $game_variables[cmdvariable]=Kernel.pbShowCommands(msgwindow,commands,cmdIfCancel)
    $game_map.need_refresh = true if $game_map
  end
  if commandProc
    ret=commandProc.call(msgwindow)
  end
  msgback.dispose if msgback
  goldwindow.dispose if goldwindow
  coinwindow.dispose if coinwindow
  apwindow.dispose if apwindow
  facewindow.dispose if facewindow
  if haveSpecialClose
    pbSEPlay(pbStringToAudioFile(specialCloseSE))
    atTop=(msgwindow.y==0)
    for i in 0..20
      if atTop
        msgwindow.y=-(msgwindow.height*(i)/20)
      else
        msgwindow.y=Graphics.height-(msgwindow.height*(20-i)/20)
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msgwindow.update
    end
  end
  return ret
end

def pbChooseNumberCentered(params)
  return 0 if !params

  ret = 0
  maximum = params.maxNumber
  minimum = params.minNumber
  defaultNumber = params.initialNumber
  cancelNumber = params.cancelNumber
  cmdwindow = Window_InputNumberPokemon.new(params.maxDigits)
  cmdwindow.x = Graphics.width / 2 - 68
  cmdwindow.y = Graphics.height / 2 - 36
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.sign = params.negativesAllowed # must be set before number
  cmdwindow.number = defaultNumber
  curnumber = defaultNumber
  command = 0
  ### MODDED/
  lastread = cmdwindow.number
  tts(cmdwindow.number.to_s)
  ### /MODDED
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    cmdwindow.update
    ### MODDED/
    if lastread != cmdwindow.number
      tts(cmdwindow.number.to_s)
      lastread = cmdwindow.number
    end
    ### /MODDED
    yield if block_given?
    if Input.trigger?(Input::C)
      ret = cmdwindow.number
      if ret > maximum
        pbPlayBuzzerSE()
      elsif ret < minimum
        pbPlayBuzzerSE()
      else
        pbPlayDecisionSE()
        break
      end
    elsif Input.trigger?(Input::B)
      pbPlayCancelSE()
      ret = cancelNumber
      pbWait(2)
      break
    end
  end
  cmdwindow.dispose
  Input.update
  return ret
end

def pbChooseNumber(msgwindow,params)
  return 0 if !params
  ret=0
  maximum=params.maxNumber
  minimum=params.minNumber
  defaultNumber=params.initialNumber
  cancelNumber=params.cancelNumber
  cmdwindow=Window_InputNumberPokemon.new(params.maxDigits)
  cmdwindow.z=99999
  cmdwindow.visible=true
  cmdwindow.setSkin(params.skin) if params.skin
  cmdwindow.sign=params.negativesAllowed # must be set before number
  cmdwindow.number=defaultNumber
  curnumber=defaultNumber
  pbPositionNearMsgWindow(cmdwindow,msgwindow,:right)
  command=0
  ### MODDED/
  lastread = cmdwindow.number
  tts(cmdwindow.number.to_s)
  ### /MODDED
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    cmdwindow.update
    msgwindow.update if msgwindow
    ### MODDED/
    if lastread != cmdwindow.number
      tts(cmdwindow.number.to_s)
      lastread = cmdwindow.number
    end
    ### /MODDED
    yield if block_given?
    if Input.trigger?(Input::C)
      ret=cmdwindow.number
      if ret>maximum
        pbPlayBuzzerSE()
      elsif ret<minimum
        pbPlayBuzzerSE()
      else
        pbPlayDecisionSE()
        break
      end
    elsif Input.trigger?(Input::B)
      pbPlayCancelSE()
      ret=cancelNumber
      pbWait(2)
      break
    end
  end
  cmdwindow.dispose
  Input.update
  return ret 
end

