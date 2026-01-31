InjectionHelper.defineMapPatch(455, 3) { |event|
  event.patch(:visnteviljustanasshole) { |page|
    matched = page.lookForAll([:ShowText, "But that does it for my explanation!"])

    for insn in matched
      page.insertBefore(insn,
        [:ShowText, "Wait, can't \\PN keep their eyes closed..."],
        [:ShowText, "Didn't really plan for a blind player. Ah, así es la vida."])
    end
  }
}

[11, 12, 92, 93, 94].each { |i|
  InjectionHelper.defineMapPatch(449, i) { |evt|
    evt.name = "Battle"
    evt.pages[0].changeTrigger(:Interact)
  }
}
