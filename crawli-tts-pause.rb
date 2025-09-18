class PokemonMenu_Scene
  alias :crawlittspause_old_pbStartScene :pbStartScene

  def pbStartScene
    crawlittspause_old_pbStartScene
    @sprites["cmdwindow"].notts
  end

  def pbShowCommands(commands)
    ret=-1
    cmdwindow=@sprites["cmdwindow"]
    cmdwindow.viewport=@viewport
    cmdwindow.index=$PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.commands=commands
    cmdwindow.x=Graphics.width-cmdwindow.width
    cmdwindow.y=0
    cmdwindow.visible=true
    lastread = nil ### MODDED
    loop do
      cmdwindow.update
      ### MODDED/
      if commands[cmdwindow.index] != lastread
        tts(commands[cmdwindow.index])
        lastread = commands[cmdwindow.index]
      end
      ### /MODDED
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B)
        ret=-1
        break
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        $PokemonTemp.menuLastChoice=ret
        break
      end
    end
    return ret
  end
end
