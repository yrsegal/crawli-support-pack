Events.onStepTaken += proc {
  playWeatherOrDiveBGS
}

WEATHER_BGS = {
  Rain: "Weather- Rain",
  Storm: "Weather- Storm",
  HeavyRain: "Weather- Storm",
  Winds: "Weather- Wind",
}

BLINDSTEP_WEATHER_BGS = {
  Snow: "Weather- Snow (Blindstep)",
  Blizzard: "Weather- Snow (Blindstep)",
  Sandstorm: "Weather- Sandstorm (Blindstep)",
  Sunny: "Weather- Sun (Blindstep)",
}

# Play BGS while over a dive spot
def playWeatherOrDiveBGS
  # return unless Reborn

  if $game_switches[:Blindstep]
    if $game_player.terrain_tag == PBTerrain::DeepWater
      pbAccessiblilityBGSPlay("Ambient Depth")
      return
    end
    if $PokemonGlobal.diving
      divemap = $cache.mapdata[$game_map.map_id].SurfaceMap
      if !divemap.nil? && $MapFactory.getTerrainTag(divemap, $game_player.x, $game_player.y) == PBTerrain::DeepWater
        pbAccessiblilityBGSPlay("Ambient Light")
        return
      end
    end
  end

  weatherBGS = WEATHER_BGS
  weatherBGS.merge!(BLINDSTEP_WEATHER_BGS) if $game_switches[:Blindstep]
  if weatherBGS[$game_screen.weather_type]
    pbAccessiblilityBGSPlay(weatherBGS[$game_screen.weather_type])
  else
    pbBGSStop(0.5)
  end

  playingBGS = $game_system.getPlayingBGS
  if !playingBGS.nil? && ["Ambient Light", "Ambient Depth"].include?(playingBGS.name)
    if $game_map.map.autoplay_bgs
      pbBGSPlay($game_map.bgs)
    else
      pbBGSStop(0.5)
    end
  end
end

class Game_Map
  alias :crawliweather_old_autoplay :autoplay

  def autoplay(from_startup = false)
    playWeatherOrDiveBGS
    crawliweather_old_autoplay(from_startup)
  end
end
