# Note - Crawli gym referring to Crawli's actual gym, despite the name of the pack

Switches[:ElevationSwitch] = 476

def yeeteventcode(from, to)
  return [
    [:PlaySoundEvent, "jump"],
    [:ConditionalBranch, :Character, :Player, :Up],
      [:SetMoveRoute, :Player, [false,
        :SetIntangible,
        [:Jump, to[0]-from[0], to[1]-from[1] - 1],
        :SetTangible,
        :Done]],
    :Else,
      [:ConditionalBranch, :Character, :Player, :Left],
        [:SetMoveRoute, :Player, [false,
          :SetIntangible,
          [:Jump, to[0]-from[0] - 1, to[1]-from[1]],
          :SetTangible,
          :Done]],
      :Else,
        [:ConditionalBranch, :Character, :Player, :Right],
          [:SetMoveRoute, :Player, [false,
            :SetIntangible,
            [:Jump, to[0]-from[0] + 1, to[1]-from[1]],
            :SetTangible,
            :Done]],
        :Else,
          [:ConditionalBranch, :Character, :Player, :Down],
            [:SetMoveRoute, :Player, [false,
              :SetIntangible,
              [:Jump, to[0]-from[0], to[1]-from[1] + 1],
              :SetTangible,
              :Done]],
          :Done,
        :Done,
      :Done,
    :Done,
    
    :WaitForMovement,
    [:Script, "$scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,$game_player.x,$game_player.y,true)"],
  ]
end

InjectionHelper.defineMapPatch(65) { |map|
  map.createSinglePageEvent(8, 62, "Accessibility Helper 1") { |page|
    page.setGraphic("trchar039")
    page.interact(
      [:ShowText, "Would you like me to yeet you past this jumping section?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        *yeeteventcode([8, 62], [23, 67]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }

  map.createSinglePageEvent(22, 69, "Accessibility Helper 2") { |page|
    page.setGraphic("trchar039", direction: :Right)
    page.interact(
      [:ShowText, "Would you like me to yeet you back across the jumping section?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        *yeeteventcode([22, 69], [8, 64]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }

  map.createSinglePageEvent(26, 68, "Accessibility Helper 3") { |page|
    page.setGraphic("trchar039", direction: :Left)
    page.interact(
      [:ShowText, "Would you like me to yeet you past this jumping section?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        *yeeteventcode([26, 68], [33, 62]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }

  map.createSinglePageEvent(32, 62, "Accessibility Helper 4") { |page|
    page.setGraphic("trchar039", direction: :Right)
    page.interact(
      [:ShowText, "Would you like me to yeet you back across the jumping section?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        *yeeteventcode([32, 62], [25, 65]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }

  map.createSinglePageEvent(31, 59, "Accessibility Helper 5") { |page|
    page.setGraphic("trchar039", direction: :Right)
    page.interact(
      [:ShowText, "Would you like me to yeet you to the Pinsir?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        [:ControlSwitch, :ElevationSwitch, true],
        *yeeteventcode([31, 59], [36, 53]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }

  map.createSinglePageEvent(37, 48, "Accessibility Helper 6") { |page|
    page.setGraphic("trchar039")
    page.interact(
      [:ShowText, "Would you like me to yeet you to the end of this trial?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        [:ControlSwitch, :ElevationSwitch, false],
        *yeeteventcode([37, 48], [33, 49]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }

  map.createSinglePageEvent(37, 45, "Accessibility Helper 6") { |page|
    page.setGraphic("trchar039", direction: :Left)
    page.interact(
      [:ShowText, "Would you like me to yeet you all the way back?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "No problem!"],
        *yeeteventcode([37, 45], [8, 64]),
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Alright!"],
      :Done)
  }
}
