class Scene_Pokegear
  def setup
    ### MODDED/
    @cmdTime=-1
    ### /MODDED
    @cmdMap=-1
    @cmdJukebox=-1
    @cmdAchievements=-1
    @cmdRift=-1
    @cmdScent=-1
    @cmdTutor=-1
    @buttons = []
    ### MODDED/
    @buttons[@cmdTime=@buttons.length] = "Time and Weather" if shouldDivergeTime?
    ### /MODDED
    @buttons[@cmdMap=@buttons.length] = "Map"
    @buttons[@cmdJukebox=@buttons.length] = "Jukebox"
    @buttons[@cmdAchievements=@buttons.length] = "Achievements"
    @buttons[@cmdRift=@buttons.length] = "Rift Dex" if $game_switches[:RiftDex]
    @buttons[@cmdScent=@buttons.length] = "Spice Scent" 
    if $Trainer.tutorlist && ($game_switches[:NotPlayerCharacter] == false ||  $game_switches[:InterceptorsWish] == true)
      @buttons[@cmdTutor=@buttons.length] = "Move Tutor"
    end 
  end

  alias :crawlipokegeartime_old_checkChoice :checkChoice

  def checkChoice
    if @cmdTime>=0 && @sprites["command_window"].index==@cmdTime
      time = pbGetTimeNow
      tts(time.strftime("%A %e %B"))
      tts("Current Time: " + time.strftime("%k %M"))
      if $game_screen.weather_type == 0
        tts("Current Weather: None")
      elsif $game_screen.weather_type.is_a?(Symbol)
        tts("Current Weather: " + $game_screen.weather_type.to_s)
      end
      tts("Location: " + $game_map.name.to_s)
    end

    crawlipokegeartime_old_checkChoice
  end
end