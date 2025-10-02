InjectionHelper.defineMapPatch(12) { |map|
  map.createNewEvent(42, 34, "Accessibility Helper") { |event|
    event.newPage { |page|
      page.setGraphic("trchar244", direction: :Left)
      page.interact(
        [:ShowText, "Hehe... want me to call the Shuppet over here?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowText, "Okaaaaay!"],
          [:PlaySoundEvent, 'PRSFX- Light Screen'],
          [:ScreenFlash, Color.new(255,255,255,255), 30],
          [:SetMoveRoute, :This, [false,
            [:SetCharacter, '', 0, :Down, 0],
            :Done]],
          [:ControlVariable, 525, :[]=, :Constant, 4],
          [:ControlSwitches, 1039, 1041, true],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "Okaaaaay..."],
          [:ShowText, "That's fine!"],
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(525, 4)
    }
  }
}
