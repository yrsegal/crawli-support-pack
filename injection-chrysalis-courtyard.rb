InjectionHelper.defineMapPatch(391) { |map|
  map.createSinglePageEvent(22, 49, "Accessibility Helper Maze") { |page|
    page.setGraphic("NPC 31")
    page.requiresVariable(679, 1)

    page.interact(
      [:ShowText, "SERVANT: Master Indriad has demanded I provide accessibility services."],
      [:ShowText, "Shall I warp you to the end of the maze?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
        [:TransferPlayer, :Constant, 391, 28, 16, :Up, true],
      :Done,
      [:When, 1, "No"],
        [:ShowText, "SERVANT: Very well."],
      :Done)
  }

  map.createNewEvent(30, 10, "Accessibility Helper Maze Return") { |event|
    event.newPage { |page|
      page.setGraphic("NPC 31")

      page.interact(
        [:ShowText, "SERVANT: Master Indriad has demanded I provide accessibility services."],
        [:ShowText, "Shall I warp you to the beginning of the maze?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
          [:TransferPlayer, :Constant, 391, 28, 58, :Down, true],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "SERVANT: Very well."],
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(679, 3)
    }
  }

  map.createNewEvent(89, 37, "Accessibility Helper Sliding Puzzle") { |event|
    event.newPage { |page|
      page.setGraphic("NPC 31")

      page.interact(
        [:ShowText, "SERVANT: Master Indriad has demanded I provide accessibility services."],
        [:ShowText, "Shall I complete this puzzle for you?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
          [:ControlVariable, 680, :[]=, :Constant, 5],
          [:TransferPlayer, :Constant, 391, 86, 32, :Up, true],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "SERVANT: Very well."],
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(680, 5)
    }
  }
}

InjectionHelper.defineMapPatch(397) { |map|
  map.createSinglePageEvent(16, 61, "Accessibility Helper Final Trial") { |page|
    page.setGraphic("NPC 31")

    page.interact(
        [:ShowText, "SERVANT: Master Indriad has demanded I provide accessibility services."],
        [:ShowText, "Shall I complete this puzzle for you, Marianette?"],
        [:ShowChoices, ["Yes!", "No..."], 2],
        [:When, 0, "Yes!"],
          [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
          [:FadeOutBackgroundMusic, 1],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:Wait, 10],
          :TimerOff,
          [:ControlVariable, 682, :[]=, :Constant, 4],
        :Done,
        [:When, 1, "No..."],
          [:ShowText, "SERVANT: Very well."],
        :Done)
  }
}
