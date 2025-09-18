class Game_Character
  def update
    return if $game_temp.menu_calling
    #cass note: pulled from Walk_Run
    if @dependentEvents
      for i in 0...@dependentEvents.length
        if @dependentEvents[i][0]==$game_map.map_id &&
           @dependentEvents[i][1]==self.id
          @move_speed=$game_player.move_speed
          break
        end
      end
    end
    if jumping?
      update_jump
    elsif moving?
      update_move
    elsif !(self==$game_player && $PokemonGlobal.fishing)
      update_stop
    end

    ### MODDED/
    Blindstep.character_update() if BlindstepActive && self == $game_player
    ### /MODDED

    update_pattern unless self==$game_player && $PokemonGlobal.fishing
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    if @move_route_forcing
      move_type_custom
      return
    end
    if @starting || @locked
      return
    end
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      case @move_type
        ### MODDED/
        when 1 then move_type_random unless BlindstepActive
        ### /MODDED
        when 2 then move_type_toward_player
        when 3 then move_type_custom
      end
    end
  end
end


class Game_Player

  def move_down(turn_enabled = true)
    if turn_enabled
      turn_down
    end
    if passable?(@x, @y, 2)
      if !@direction_fix
        return if pbLedge(0,1)
      end
      return if pbEndSurf(0,1)
      return if pbEndLavaSurf(0,1)
      turn_down if turn_enabled
      @y += 1
      ### MODDED/
      Blindstep.player_move(2) if BlindstepActive
      ### /MODDED
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x, @y-1)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x, @y+1)
        if !@bump_se || @bump_se<=0
          pbSEPlay("bump")
          @bump_se=10
        end
      end
    end
  end

  def move_left(turn_enabled = true)
    if turn_enabled
      turn_left
    end
    if passable?(@x, @y, 4)
      if !@direction_fix
         return if pbLedge(-1,0)
      end
      return if pbEndSurf(-1,0)
      return if pbEndLavaSurf(-1,0)
      turn_left if turn_enabled
      @x -= 1
      ### MODDED/
      Blindstep.player_move(4) if BlindstepActive
      ### /MODDED
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x+1, @y)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x-1, @y)
        if !@bump_se || @bump_se<=0
          pbSEPlay("bump")
          @bump_se=10
        end
      end
    end
  end

  def move_right(turn_enabled = true)
    if turn_enabled
      turn_right
    end
    if passable?(@x, @y, 6)
      if !@direction_fix
        return if pbLedge(1,0)
      end
      return if pbEndSurf(-1,0)
      return if pbEndLavaSurf(-1,0)
      turn_right if turn_enabled
      @x += 1
      ### MODDED/
      Blindstep.player_move(6) if BlindstepActive
      ### /MODDED
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x-1, @y)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x+1, @y)
        if !@bump_se || @bump_se<=0
          pbSEPlay("bump")
          @bump_se=10
        end
      end
    end
  end

  def move_up(turn_enabled = true)
    if turn_enabled
      turn_up
    end
    if passable?(@x, @y, 8)
      if !@direction_fix
         return if pbLedge(0,-1)
      end
      return if pbEndSurf(0,-1)
      return if pbEndSurf(-1,0)
      return if pbEndLavaSurf(0,-1)
      return if pbEndLavaSurf(-1,0)
      turn_up if turn_enabled
      @y -= 1
      ### MODDED/
      Blindstep.player_move(8) if BlindstepActive
      ### /MODDED
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x, @y+1)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x, @y-1)
        if !@bump_se || @bump_se<=0
          pbSEPlay("bump")
          @bump_se=10
        end
      end
    end
  end
end
