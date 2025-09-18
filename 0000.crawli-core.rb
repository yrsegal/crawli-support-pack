# Using this to replace the game switch from reborn - if you installed this pack, you want blindstep
BlindstepActive = true

def internal_se_play(name, volume, pitch, x, y, z)
  defined?(Audio.se_play_position) ? Audio.se_play_position(name, volume, pitch, x, y, z) : Audio.se_play(name, volume, pitch)
end

class Game_System
  def accessible_se_play(se, x: 0, y: 0, z: 0)
    if se.is_a?(String)
      se = RPG::AudioFile.new(se)
    end
    if se != nil && se.name != ""
      se.name = File.basename(se.name, File.extname(se.name))
      path = File.join(__dir__[Dir.pwd.length+1..]}, "Sounds/"+se.name)
      if FileTest.audio_exist?(path)
        internal_se_play(path, self.resolve_volume(se.volume), se.pitch, x, y, z)
      end
    end
  end

  def accessible_bgs_play(bgs)
    @playing_bgs = bgs==nil ? nil : bgs.clone
    if bgs != nil && bgs.name != ""
      path = File.join(__dir__[Dir.pwd.length+1..]}, "BGSounds/"+bgs.name)
      if FileTest.audio_exist?(path)
        Audio.bgs_play(path, self.resolve_volume(bgs.volume), bgs.pitch)
      end
    else
      @bgs_position=0
      @playing_bgs=nil
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end
end

def pbAccessibilitySEPlay(param, volume = nil, pitch = nil, x: 0, y: 0, z: 0)
  return if !param

  if $Settings.accessibilityVolume
    if volume && $Settings.accessibilityVolume
      volume *= ($Settings.accessibilityVolume / 100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.accessibilityVolume
      volume = param.volume * ($Settings.accessibilityVolume / 100.00)
    elsif !volume && $Settings.accessibilityVolume
      volume = $Settings.accessibilityVolume
    end
  else
    volume = 100
  end
  param = pbResolveAudioFile(param.clone, volume, pitch)
  if param.name && param.name != ""
    if $game_system && $game_system.respond_to?("accessible_se_play")
      $game_system.accessible_se_play(param, x: x, y: y, z: z)
      return
    elsif (RPG.const_defined?(:SE) rescue false)
      b = RPG::SE.new(param.name, param.volume, param.pitch)
      if b && b.respond_to?("play")
        b.play
        return
      end
    end
    internal_se_play(canonicalize(File.join(__dir__[Dir.pwd.length+1..]}, "Sounds/"+param.name)), param.volume, param.pitch, x, y, z)
  end
end

def pbAccessibilityBGSPlay(param,volume=nil,pitch=nil)
  return if !param
  if $Settings.volume
    if volume && $Settings.volume
      volume = volume * ($Settings.volume/100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.volume
      volume = param.volume * ($Settings.volume/100.00)
    elsif !volume && $Settings.volume
      volume = $Settings.volume 
    end
  else
    volume=100
  end
  param=pbResolveAudioFile(param.clone,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("accessible_bgs_play")
      $game_system.accessible_bgs_play(param)
      return
    elsif (RPG.const_defined?(:BGS) rescue false)
      b=RPG::BGS.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.bgs_play(canonicalize(File.join(__dir__, "BGSounds/"+param.name)),param.volume,param.pitch)
  end
end

module Blindstep
  @@step = false

  def self.player_move(direction)
    stepVolume = $Settings.footstepVolume
    return if stepVolume == 0
    return if $Settings.accessibilityVolume == 0

    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      pbAccessibilitySEPlay("Blindstep- Waterstep_D", stepVolume, @@step ? 80 : 100) if direction == 2
      pbAccessibilitySEPlay("Blindstep- Waterstep", stepVolume, @@step ? 80 : 100, x: Math.sin(-60 * Math::PI / 180), z: Math.cos(-60 * Math::PI / 180)) if direction == 4
      pbAccessibilitySEPlay("Blindstep- Waterstep", stepVolume, @@step ? 80 : 100, x: Math.sin(60 * Math::PI / 180), z: Math.cos(60 * Math::PI / 180)) if direction == 6
      pbAccessibilitySEPlay("Blindstep- Waterstep_U", stepVolume, @@step ? 80 : 100) if direction == 8
    else
      pbAccessibilitySEPlay("Blindstep- Footstep_D", stepVolume, @@step ? 80 : 100) if direction == 2
      pbAccessibilitySEPlay("Blindstep- Footstep_L", stepVolume, @@step ? 80 : 100) if direction == 4
      pbAccessibilitySEPlay("Blindstep- Footstep_R", stepVolume, @@step ? 80 : 100) if direction == 6
      pbAccessibilitySEPlay("Blindstep- Footstep_U", stepVolume, @@step ? 80 : 100) if direction == 8
    end
    @@step = !@@step
  end

  def self.character_update()
    return if pbMapInterpreterRunning? || $game_temp.message_window_showing
    return if $Settings.accessibilityVolume == 0

    rate = $Settings.ambientRate
    remainder = Graphics.frame_count % (rate * ($speed_up ? 5 : 1)).floor

    if remainder == 0
      self.playAmbientSounds
      return if self.getFacingEventType == 0

      eventVolume = $Settings.eventVolume
      return if eventVolume == 0

      playerDirection = $game_player.direction
      case playerDirection
        when 8
          # pbAccessibilitySEPlay("Blindstep- Door", eventVolume, 80) if door
          pbAccessibilitySEPlay("Blindstep- ImmediateEvent", eventVolume, 80)
        when 2
          # pbAccessibilitySEPlay("Blindstep- Door", eventVolume, 20) if door
          pbAccessibilitySEPlay("Blindstep- ImmediateEvent", eventVolume, 20)
        when 4
          # pbAccessibilitySEPlay("Blindstep- DoorL", eventVolume) if door
          pbAccessibilitySEPlay("Blindstep- ImmediateEventL", eventVolume)
        when 6
          # pbAccessibilitySEPlay("Blindstep- DoorR", eventVolume) if door
          pbAccessibilitySEPlay("Blindstep- ImmediateEventR", eventVolume)
      end
    end
  end

  def self.playAmbientSounds
    wallVolume = $Settings.wallVolume
    return if wallVolume == 0
    return if $Settings.accessibilityVolume == 0

    volumeNorth = self.getDirectionVolume(8) * wallVolume / 100.0
    volumeSouth = self.getDirectionVolume(2) * wallVolume / 100.0
    volumeWest = self.getDirectionVolume(4) * wallVolume / 100.0
    volumeEast = self.getDirectionVolume(6) * wallVolume / 100.0

    pbAccessibilitySEPlay("Blindstep- AmbientNorth", volumeNorth) if volumeNorth > 0
    pbAccessibilitySEPlay("Blindstep- AmbientSouth", volumeSouth) if volumeSouth > 0
    pbAccessibilitySEPlay("Blindstep- AmbientWest", volumeWest) if volumeWest > 0
    pbAccessibilitySEPlay("Blindstep- AmbientEast", volumeEast) if volumeEast > 0
  end

  def self.getDirectionVolume(direction)
    radius = $Settings.wallRange
    x = $game_player.x
    y = $game_player.y
    intensity = radius
    while intensity > 0
      break unless $game_player.passable?(x, y, direction)

      intensity -= 1
      y += 1 if direction == 2
      x -= 1 if direction == 4
      x += 1 if direction == 6
      y -= 1 if direction == 8
    end
    return 100 * intensity / radius
  end

  def self.getFacingEventType
    event = $game_player.pbFacingEvent
    return 0 unless event
    # Ignore non-interactable events
    return 0 if event.trigger != 0 || event.list.length <= 1
    return 2 if event.name == "Item"

    # TODO: Separate value for door
    return 1
  end

  # TODO: This doesn't handle regions since Reborn only has one.
  def self.flyMenu()
    items = {}
    $cache.town_map.each do |key, value|
      if value.is_a?(TownMapData) && value.flyData != [] && $PokemonGlobal.visitedMaps[value.flyData[0]]
        items[value.name] = value.flyData
      end
    end
    items = items.sort_by { |key| key }.to_h
    cmd = Kernel.pbMessage("Choose destination...", items.keys, -1)
    if cmd == -1
      return nil
    end

    return items[items.keys[cmd]]
  end
end
