InjectionHelper.defineMapPatch(119, 48, 1) { |event|
  event.patch(:droprock) { |page|
    page.insertBeforeEnd([:ControlVariable, 307, :[]=, :Constant, 1])
  }
}

InjectionHelper.defineMapPatch(107) { |map|
  map.createNewEvent(9, 9, "Accessibility Helper Puzzle 1") { |event|
    event.newPage { |page|
      page.requiresVariable(181, 2)
      page.interact(
        [:ShowText, "STATUE: Detected. Accessibility. Complete puzzle?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:PlaySoundEvent, 'PRSFX- Gear Grind'],
          [:ScreenFlash, Color.new(255,255,255,255), 20],
          [:SetEventLocation, 4, :Constant, 8, 11, :Down],
          [:SetEventLocation, 5, :Constant, 11, 13, :Down],
          [:SetEventLocation, 6, :Constant, 13, 11, :Down],
          [:Wait, 20],
          [:ShowText, "STATUE: Completed. Continue."],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "STATUE: Deactivating."],
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(514, 3)
    }
  }

  map.createNewEvent(32, 36, "Accessibility Helper Puzzle 2") { |event|
    event.newPage { |page|
      page.setGraphic("pkmn_Regirock_5")
      page.requiresVariable(514, 4)
      page.interact(
        [:ShowText, "STATUE: Detected. Accessibility. Complete puzzle?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:PlaySoundEvent, 'PRSFX- Gear Grind'],
          [:ScreenFlash, Color.new(255,255,255,255), 20],
          [:SetEventLocation, 34, :Constant, 33, 40, :Right],
          [:SetEventLocation, 36, :Constant, 39, 40, :Left],
          [:SetEventLocation, 35, :Constant, 38, 43, :Right],
          [:SetEventLocation, 37, :Constant, 39, 45, :Left],
          [:SetEventLocation, 38, :Constant, 34, 45, :Left],
          [:Wait, 20],
          [:ShowText, "STATUE: Completed. Continue."],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "STATUE: Deactivating."],
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(514, 5)
      page.setGraphic("pkmn_Regirock_5")
    }
  }

  map.createNewEvent(9, 72, "Accessibility Helper Zorua Puzzle") { |event|
    event.newPage { |page|
      page.setGraphic("pkmn_Regirock_5")
      page.requiresVariable(514, 6)
      page.interact(
        [:ShowText, "STATUE: Detected. Accessibility. Complete puzzle?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:PlaySoundEvent, 'PRSFX- Gear Grind'],
          [:ScreenFlash, Color.new(255,255,255,255), 20],
          [:SetEventLocation, 41, :Constant, 10, 74, :Right],
          [:SetEventLocation, 42, :Constant, 26, 74, :Up],
          [:SetEventLocation, 40, :Constant, 9, 80, :Left],
          [:SetEventLocation, 39, :Constant, 7, 86, :Left],
          [:SetEventLocation, 47, :Constant, 16, 87, :Right],
          [:SetEventLocation, 44, :Constant, 27, 80, :Up],
          [:SetEventLocation, 46, :Constant, 27, 86, :Down],
          [:SetEventLocation, 48, :Constant, 14, 101, :Down],
          [:SetEventLocation, 43, :Constant, 22, 101, :Up],
          [:SetEventLocation, 45, :Constant, 15, 92, :Down],
          [:Wait, 20],
          [:ShowText, "STATUE: Completed. Continue."],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "STATUE: Deactivating."],
        :Done)
    }

    event.newPage { |page|
      page.requiresSwitch(1028)
      page.setGraphic("pkmn_Regirock_5")
    }
  }
}
