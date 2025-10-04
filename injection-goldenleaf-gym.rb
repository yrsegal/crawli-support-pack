InjectionHelper.defineMapPatch(401, 7, 0) { |page|
  page.patch(:addskip) { |page|
    page.insertBeforeEnd(
      [:ShowText, "The Rotoms seem strangely polite about you."],
      [:ShowText, "They're willing to escort you alone, for some reason..."]
      [:When, 0, "Yes"],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:PlaySoundEvent, 'PRSFX- Teleport', 100, 100],
        [:Wait, 12],
        [:ControlVariable, 370, :[]=, :Constant, 21],
        [:TransferPlayer, 401, 24, 45, :Down, true],
        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
