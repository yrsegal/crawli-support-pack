def showMovesetForMon(pkmn)
  cmdwin=pbListWindow([],200)
  helpwin=Window_UnformattedTextPokemon.new("")

  levelup = []
  tms = []
  tutors = []
  egg = []

  tmmoves = []

  pbEachNaturalMove(pkmn){|move,level|
    lvname = level == 0 ? _INTL("Evolution") : _INTL("Level {1}", level)
    levelup.push(_INTL("{1} - {2}", lvname, getMoveName(move)))
  }

  $cache.items.keys.each { |item|
    if pbIsTM?(item)
      move = pbGetTM(item)
      tmmoves.push(move)
      if pkmn.SpeciesCompatible?(move)
        tms.push(_INTL("{1} {2}", getItemName(item), getMoveName(move)))
      end
    end
  }

  tmmovelist = pkmn.formCheck(:compatiblemoves)
  tmmovelist = $cache.pkmn[pkmn.species].compatiblemoves if tmmovelist.nil?

  tmmovelist.each { |move|
    if !tmmoves.include?(move)
      tutors.push(getMoveName(move))
    end
  }

  pkmn.getEggMoveList.each { |move|
    egg.push(getMoveName(move))
  }

  commands = [levelup, tms, tutors, egg]
  descs = [_INTL("Level Up Moves"), _INTL("TM Moves"), _INTL("Tutor Moves"), _INTL("Egg Moves")]

  entries = []
  for i in 0...4
    entries.push([commands[i], descs[i]]) unless commands[i].empty?
  end

  pbListMulti(cmdwin,helpwin,entries) 
  cmdwin.dispose
  helpwin.dispose
end

def pbListMulti(cmdwindow,helpwindow,commands)
  cmdwindow.z=99999
  cmdwindow.visible=true
  newCommands, newText = commands[0]
  tts(newText)
  cmdwindow.commands = newCommands
  helpwindow.text = newText
  cmdwindow.width=256
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.active=true

  helpwindow.z=99999
  helpwindow.visible=true
  helpwindow.resizeToFit(helpwindow.text,Graphics.width)
  helpwindow.x = Graphics.width - helpwindow.width
  helpwindow.y = Graphics.height - helpwindow.height

  commandPositions = commands.map { 0 }
  cmdpos = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      break
    elsif Input.trigger?(Input::LEFT)
      cmdpos -= 1
      cmdpos += commandPositions.length if cmdpos < 0
      newCommands, newText = commands[cmdpos]
      tts(newText)
      cmdwindow.commands = newCommands
      helpwindow.text = newText
      cmdwindow.index = commandPositions[cmdpos]
      helpwindow.resizeToFit(helpwindow.text,Graphics.width)
      helpwindow.x = Graphics.width - helpwindow.width
      helpwindow.y = Graphics.height - helpwindow.height
      pbPlayCursorSE
    elsif Input.trigger?(Input::RIGHT)
      cmdpos += 1
      cmdpos = 0 if cmdpos >= commandPositions.length
      newCommands, newText = commands[cmdpos]
      tts(newText)
      cmdwindow.commands = newCommands
      helpwindow.text = newText
      cmdwindow.index = commandPositions[cmdpos]
      helpwindow.resizeToFit(helpwindow.text,Graphics.width)
      helpwindow.x = Graphics.width - helpwindow.width
      helpwindow.y = Graphics.height - helpwindow.height
      pbPlayCursorSE
    end
  end
  cmdwindow.active=false
end
