InjectionHelper.defineMapPatch(339, 95) { |event|
  event.patch(:quizhint) { |page|
    matched = page.lookForAll([:ShowText, /\[A\] key/]) +
              page.lookForAll([:ShowTextContinued, /\[A\] key/])

    for insn in matched
      page.insertAfter(insn, [:ShowText, "And honey, if you're blind, here's a little secret! Don't tell anyone, but you can \\c[6]hold the [A] button!"])
    end
  }
}

InjectionHelper.defineMapPatch(339) { |map|
  map.createNewEvent(56, 94, "Accessibility Helper") { |event|
    event.newPage { |page|
      page.setGraphic("NPC 31")

      page.interact(
        [:ShowText, "SERVANT: Lady Angie has demanded I provide accessibility services."],
        [:ShowText, "Shall I bypass this puzzle for you?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ScreenFlash, Color.new(255,255,255,255), 10],
          [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
          [:ControlSwitch, 1449, true],
          [:ControlSwitch, 1450, true],
          [:ControlSwitch, 1636, true],
          [:SetEventLocation, 33, :Constant, 52, 96, :Left],
          [:SetEventLocation, 44, :Constant, 81, 96, :Left],
          [:SetEventLocation, 55, :Constant, 95, 72, :Left],
          [:Wait, 10],
          [:PlaySoundEvent, 'GlassBreak', 100, 150],
          [:ShowText, "SERVANT: The ladders have been moved into place."],
          [:ShowText, "The glass has been broken for you as well."],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "SERVANT: Very well."],
        :Done)
    }
  }
}
