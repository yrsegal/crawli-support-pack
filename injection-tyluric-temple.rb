InjectionHelper.defineMapPatch(179, 63) { |event|
  event.patch(:whirlwindskip) { |page|
    page.insertBeforeEnd(
      [:ShowText, "Would you like to skip the whirlwind puzzle?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ControlVariable, 719, :[]=, :Constant, 6],
      :Done,
      [:When, 1, "No"],
      :Done)
  }

  event.newPage { |page|
    page.requiresVariable(719, 6)
  }
}

InjectionHelper.defineMapPatch(179, 14, 0) { |page|
  page.patch(:mirrorskip) {
    page.insertAtStart(
      [:ShowText, "Do you want to skip the mirror puzzle?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ControlVariable, 502, :[]=, :Constant, 1],
        [:ControlVariable, 503, :[]=, :Constant, 1],
        [:ControlVariable, 504, :[]=, :Constant, 1],
        [:ControlVariable, 505, :[]=, :Constant, 0],
        [:ControlVariable, 506, :[]=, :Constant, 1],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}

InjectionHelper.defineMapPatch(181) { |map|
  map.createSinglePageEvent(98, 9, "Accessibility Warp Past Tornadoes") { |page|
    page.interact(
      [:ShowText, "Would you like to warp past the tornadoes?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, 'SFX- GBC Teleport'],
        [:TransferPlayer, :Constant, 181, 116, 9, :Up, true],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}

InjectionHelper.defineMapPatch(181, 54, 1) { |page|
  page.patch(:whirlwindinfo) {
    matched = page.lookForSequence([:PlaySoundEvent, nil])
    if matched
      page.insertAfter(matched,
        [:ShowText, "A whirlwind on the temple surface activated!"])
      next true
    end
  }
}
