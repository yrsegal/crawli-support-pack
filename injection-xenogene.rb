InjectionHelper.defineMapPatch(451, 55) { |event|
  event.patch(:xenogenestealth) { |page|
    matched = page.lookForSequence([:ControlVariable, 620, :[]=, :Constant, 62])

    if matched
      page.insertAfter(matched,
        [:ShowText, "Do you want to skip this stealth segment?"],
        [:ShowChoices, ["No", "Yes"], 1],
        [:When, 0, "No"],
        :Done,
        [:When, 1, "Yes"],
          [:ShowText, "Let's do it in post!"],
          [:ControlVariable, 620, :[]=, :Constant, 68],
          [:PlaySoundEvent, 'Entering Door', 80, 100],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:Wait, 10],
          [:TransferPlayer, :Constant, 451, 42, 100, true],
          [:Script, 'Kernel.pbRemoveDependency2("AdelindeDep2")'],
          [:Wait, 10],
          [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
        :Done)
    end
  }
}
