class PokemonReadyMenu_Scene

  def pbStartScene(commands)
    @commands = commands
    @movecommands = []
    @itemcommands = []
    for i in 0...@commands[0].length
      @movecommands.push(@commands[0][i][1])
    end
    for i in 0...@commands[1].length
      @itemcommands.push(@commands[1][i][1])
    end
    @index = $PokemonBag.registeredIndex
    if @index[0]>=@movecommands.length && @movecommands.length>0
      @index[0] = @movecommands.length-1
    end
    if @index[1]>=@itemcommands.length && @itemcommands.length>0
      @index[1] = @itemcommands.length-1
    end
    if @index[2]==0 && @movecommands.length==0
      @index[2] = 1
    elsif @index[2]==1 && @itemcommands.length==0
      @index[2] = 0
    end
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new((@index[2]==0) ? @movecommands : @itemcommands,tts:false) ### MODDED
    #@sprites["cmdwindow"].height = @itemcommands.length*32
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport
    #pbSEPlay("GUI menu open")
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