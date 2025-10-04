InjectionHelper.defineMapPatch(484) { |map| # Venam's Gym
  map.createSinglePageEvent(40, 28, "Accessibility Helper Left 1") { |page|
    page.setGraphic("trchar244")
    page.interact(
      [:ShowText, "Hi! I'm here to help people with impaired sight."],
      [:ShowText, "Would you like to bypass these effect tiles?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, 'SFX- GBC Teleport'],
        [:TransferPlayer, :Constant, 484, 40, 22, :Up, true],
      :Done,
      [:When, 1, "No"],
        [:ShowText, "That's fine!"],
      :Done)
  }

  map.createSinglePageEvent(41, 18, "Accessibility Helper Left 2") { |page|
    page.setGraphic("trchar244")
    page.interact(
      [:ShowText, "Hi! I'm here to help people with impaired sight."],
      [:ShowText, "Would you like to bypass these effect tiles?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, 'SFX- GBC Teleport'],
        [:TransferPlayer, :Constant, 484, 40, 11, :Up, true],
      :Done,
      [:When, 1, "No"],
        [:ShowText, "That's fine!"],
      :Done)
  }

  map.createSinglePageEvent(59, 29, "Accessibility Helper Right") { |page|
    page.setGraphic("trchar244", direction: :Left)
    page.interact(
      [:ShowText, "Hi! I'm here to help people with impaired sight."],
      [:ShowText, "Would you like to bypass these effect tiles?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, 'SFX- GBC Teleport'],
        [:TransferPlayer, :Constant, 484, 57, 22, :Up, true],
      :Done,
      [:When, 1, "No"],
        [:ShowText, "That's fine!"],
      :Done)
  }
}
