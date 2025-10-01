class PokemonAchievementsScene
  def update
    if @sprites["command_window"].nil?
      pbUpdateSpriteHash(@sprites)
      return true
    end
    for i in 0...@sprites["command_window"].commands.length
      sprite=@sprites["button#{i}"]
      sprite.selected=(i==@sprites["command_window"].index) ? true : false
      if sprite.selected
        desc = @achievements[i][:description]
        prog = $Trainer.achievements.getProgress(@achievementInternalNames[i])
        goal = $Trainer.achievements.getMilestone(@achievementInternalNames[i])
# hidden achievements
#        if i==0 && !$game_switches[1499]
#          desc = "Cannot use yet"
#          prog = "XXXX"
#          goal = "XXXX"
#        end
        ###MODDED/
        level = $Trainer.achievements.getMilestone(@achievementInternalNames[i])
        levelMax = @achievements[i][:milestones].length
        if desc != @lastdesc
          tts(_INTL(desc))
          tts(_iNTL("Level: {1}/{2}",level,levelMax))
          tts(_INTL("Progress: {1}/{2}",prog,goal))
          @lastdesc = desc
        end
        ###/MODDED

        @sprites["achievementText"].change(_INTL(desc),_INTL("Progress: {1}/{2}",prog,goal))
      end
    end
    if @sprites["command_window"].index==0
      @offset=0
    end
    if @sprites["command_window"].index==@buttons.length-1
      @offset=@buttons.length-6
    end
    if @sprites["command_window"].index>@offset+4
      @offset+=1
    end
    if @sprites["command_window"].index<@offset
      @offset-=1
    end
    for i in 0...@buttons.length
      @sprites["button#{i}"].visible = false
      @sprites["button#{i}"].y=46 + ((i-@offset)*50)
    end
    for i in @offset...@offset+5
      @sprites["button#{i}"].visible = true
    end
    pbUpdateSpriteHash(@sprites)
  end
end
