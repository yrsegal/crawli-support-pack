InjectionHelper.defineMapPatch(431) { |map|
  map.createSinglePageEvent(18, 14, "Accessibility Option") { |page|
    page.setGraphic("trchar039")
    page.interact(
      [:ShowText, "Do you want to skip this stealth segment?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, 'Exit Door', 100, 100],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:Wait, 10],
        [:TransferPlayer, :Constant, 329, 42, 13, :Down, false],
        [:Script, 'advanceQuestSilent(:TOH,5,colorQuest("Blue"))'],
        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
        [:Wait, 10],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
