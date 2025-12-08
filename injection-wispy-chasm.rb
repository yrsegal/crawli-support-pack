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

InjectionHelper.defineMapPatch(489) { |map|
  map.createNewEvent(50, 59, "Accessibility Helper") { |event|
    event.newPage { |page|
      page.requiresSwitch(294)
      page.setGraphic("trchar018")
      page.interact(
        [:ShowText, "Hey, need some help? I can push that rock into place for you."],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowText, "Alright!"],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:PlaySoundEvent, 'Exit Door', 100, 100],
          [:Wait, 10],
          [:SetEventLocation, 79, :Constant, 55, 56, :Down],
          [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "No worries. I'm here if you need me."],
        :Done)
    }

    event.newPage { |page|
      page.requiresSwitch(320)
      page.setGraphic("trchar018")
      page.interact(
        [:ShowText, "Happy exploring."])
    }
  }
}
