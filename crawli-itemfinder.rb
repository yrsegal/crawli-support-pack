ItemHandlers::UseInField.add(:ITEMFINDER, proc { |item|
  event = pbClosestHiddenItem
  pbSEPlay("itemfinder1")
  if !event
    Kernel.pbMessage(_INTL("... ... ... ...Nope!\r\nThere's no response."))
  else
    offsetX = event.x - $game_player.x
    offsetY = event.y - $game_player.y
    if offsetX == 0 && offsetY == 0
      for i in 0...32
        Graphics.update
        Input.update
        $game_player.turn_right_90 if (i & 7) == 0
        pbUpdateSceneMap
      end
      $scene.spriteset.addUserAnimation(PLANT_SPARKLE_ANIMATION_ID,event.x,event.y,true)
      Kernel.pbMessage(_INTL("The {1}'s indicating something right underfoot!\1", getItemName(item)))
    else
      direction = $game_player.direction
      if offsetX.abs > offsetY.abs
        direction = (offsetX < 0) ? 4 : 6
      else
        direction = (offsetY < 0) ? 8 : 2
      end
      for i in 0...8
        Graphics.update
        Input.update
        if i == 0
          $game_player.turn_down if direction == 2
          $game_player.turn_left if direction == 4
          $game_player.turn_right if direction == 6
          $game_player.turn_up if direction == 8
        end
        pbUpdateSceneMap
      end
      $scene.spriteset.addUserAnimation(PLANT_SPARKLE_ANIMATION_ID,event.x,event.y,true)
      # Kernel.pbMessage(_INTL("Huh?\nThe {1}'s responding!\1",getItemName(item)))
      # Kernel.pbMessage(_INTL("There's an item buried around here!"))
      if BlindstepActive
        message = "There's an item "
        if offsetX < 0
          message += (-1 * offsetX).to_s + " tile"
          message += offsetX != -1 ? "s" : ""
          message += " left"
          message += offsetY != 0 ? " and " : ""
        elsif offsetX > 0
          message += (offsetX).to_s + " tile"
          message += offsetX != 1 ? "s" : ""
          message += " right"
          message += offsetY != 0 ? " and " : ""
        end
        if offsetY < 0
          message += (-1 * offsetY).to_s + " tile"
          message += offsetY != -1 ? "s" : ""
          message += " up"
        elsif offsetY > 0
          message += (offsetY).to_s + " tile"
          message += offsetY != 1 ? "s" : ""
          message += " down"
        end
        message += " from here!"
        Kernel.pbMessage(_INTL(message))
      end
    end
  end
})
