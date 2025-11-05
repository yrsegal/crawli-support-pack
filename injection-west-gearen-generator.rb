InjectionHelper.defineMapPatch(256, 41, 0) { |page|
  page.patch(:addskip) {
    page.insertBeforeEnd(
      [:Wait, 20],
      [:ShowAnimation, :Player, EXCLAMATION_ANIMATION_ID],
      [:ShowText, "You feel an invisible hand of electricity tugging yours!"],
      [:ShowText, "For some reason, the Rotom wants to escort you past the stealth segment."],
      [:ShowText, "Do you want to let it skip the segment for you?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:PlaySoundEvent, 'Exit Door', 100, 100],
        [:Wait, 10],
        [:TransferPlayer, :Constant, 271, 9, 39, :Up, true],
        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
