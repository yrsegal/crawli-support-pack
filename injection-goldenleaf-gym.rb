InjectionHelper.defineMapPatch(401, 7) { |event|
  event.name = "Accessibility Skip"
  event.patch(:addskip) { |page|
    page.insertBeforeEnd(
      [:ShowText, "I'm kind of fed up with it, though."],
      [:ShowText, "Want to just skip past it?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:PlaySoundEvent, 'PRSFX- Teleport', 100, 100],
        [:Wait, 12],
        [:ControlVariable, 370, :[]=, :Constant, 21],
        [:TransferPlayer, :Constant, 401, 24, 45, :Down, true],
        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
