InjectionHelper.defineMapPatch(455, 3) { |event|
  event.patch(:visnteviljustanasshole) { |page|
    matched = page.lookForAll([:ShowText, "But that does it for my explanation!"])

    if matched
      page.insertBefore(matched,
        [:ShowText, "Wait, can't \\PN keep their eyes closed..."],
        [:ShowText, "Didn't really plan for a blind player. Ah, así es la vida."])
    end
  }
}

[11, 12, 92, 93, 94].each { |i|
  InjectionHelper.defineMapPatch(449, i, 0) { |page|
    page.changeTrigger(:Interact)
  }
}
