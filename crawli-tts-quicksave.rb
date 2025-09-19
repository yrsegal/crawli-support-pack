class Scene_Map
  def update
    loop do
      updateMaps
      pbMapInterpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    if $game_temp.to_title
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" + $game_temp.transition_name)
      end
    end
    if $game_temp.message_window_showing
      return
    end
    if Input.trigger?(Input::C)
      unless pbMapInterpreterRunning?
        $PokemonTemp.hiddenMoveEventCalling=true
      end
    end

    # Pause Menu
    if Input.trigger?(Input::B)
      unless pbMapInterpreterRunning? || $game_system.menu_disabled || $game_player.moving?
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    
    #Autorun
    if Input.trigger?(Input::R) 
      unless pbMapInterpreterRunning?
        if $Settings.autorunning == 1
          $Settings.autorunning = 0
        else
          $Settings.autorunning = 1
        end
      end
    end

    # Quicksave
    
    if Input.trigger?(Input::Z)
      if $game_switches[:Disable_Quicksave]==false #&& !pbMapInterpreterRunning?
        $game_switches[:Mid_quicksave]=true
        $game_switches[:Stop_Icycle_Falling]=true
        for event in $game_map.events.values
          event.minilock
        end
        ### MODDED/
        message = sprintf("X %d, Y %d, map %d, %s", $game_player.x, $game_player.y, $game_map.map_id, $game_map.name)
        tts(message, true)
        pbWait(30)
        ### /MODDED
        if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
          if pbSave
            Kernel.pbMessage("Saved the game!")
          else
            Kernel.pbMessage("Save failed.")
          end
        end
        for event in $game_map.events.values
          event.unlock
        end
        $game_switches[:Mid_quicksave]=false
        $game_switches[:Stop_Icycle_Falling]=false
      end
    end

    # Ready menu
    if Input.trigger?(Input::Y)
      unless pbMapInterpreterRunning?
        $PokemonTemp.keyItemCalling = true if $PokemonTemp
      end
    end

    # Debug menu
    if $DEBUG && Input.press?(Input::F9)
      $game_temp.debug_calling = true
    end

    # Actually doing the action chosen
    unless $game_player.moving?
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      elsif $PokemonTemp && $PokemonTemp.keyItemCalling
        $PokemonTemp.keyItemCalling=false
        $game_player.straighten
        Kernel.pbUseKeyItem
      elsif $PokemonTemp && $PokemonTemp.hiddenMoveEventCalling
        $PokemonTemp.hiddenMoveEventCalling=false
        $game_player.straighten
        Events.onAction.trigger(self)
      end
    end
  end
end