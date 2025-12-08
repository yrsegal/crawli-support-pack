InjectionHelper.defineMapPatch(485) { |map|
  map.createNewEvent(19, 7, "Accessibility Helper") { |event|
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
          [:ControlVariable, 471, :[]=, :Constant, 5],
          [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "No worries. I'm here if you need me."],
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(471, 7)
      page.setGraphic("trchar018")
      page.interact(
        [:ShowText, "Happy exploring."])
    }
  }
}
