class PokemonReadyMenu_Scene

  alias :crawlittsreadymenu_old_pbStartScene :pbStartScene
  def pbStartScene(commands)
    crawlittsreadymenu_old_pbStartScene(commands)
    @sprites["cmdwindow"].notts
  end

  def pbShowCommands
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = @itemcommands
    cmdwindow.index    = @index[@index[2]]
    cmdwindow.visible  = true
    counter = 0
    counterlimit = $speed_up ? 20 : 8
    lastread = nil ### MODDED
    loop do
      pbUpdate
      ### MODDED/
      tts(cmdwindow.commands[cmdwindow.index]) if lastread != cmdwindow.index
      lastread = cmdwindow.index
      ### /MODDED
      if Input.trigger?(Input::B)
        ret = -1
        break
      elsif Input.trigger?(Input::C) || Input.trigger?(Input::Y) || Input.press?(Input::Y) && counter > counterlimit
        ret = [@index[2],cmdwindow.index]
        break
      elsif Input.press?(Input::Y)
        counter+=1
      end
    end
    return ret
  end
end