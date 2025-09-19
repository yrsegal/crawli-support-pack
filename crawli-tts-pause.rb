class PokemonMenu_Scene
  def pbStartScene
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["cmdwindow"]=Window_CommandPokemon.new([],tts:false) ### MODDED
    @sprites["infowindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["infowindow"].visible=false
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible=false
    @sprites["cmdwindow"].visible=false
    @infostate=false
    @helpstate=false
    $game_temp.in_menu = true
    pbSEPlay("menu")
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
