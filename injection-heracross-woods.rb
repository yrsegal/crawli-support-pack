[0, 1].each { |i|
  InjectionHelper.defineMapPatch(244, 10, i) { |page|
    page.patch(:heracrossskip) {
      page.insertBeforeEnd(
        [:ShowText, "Ask her to corral the Heracross for you?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowAnimation, :This, 4], # Question
          [:Wait, 20],
          [:ShowText, "MELIA: What is it?"],
          [:CallCommonEvent, 97], # Player talk
          [:ShowText, "MELIA: Sure, I can do that. Just give me a bit..."],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:Wait, 40],
          [:PlaySoundEvent, 'PRSFX- Trainer', 80, 100],
          [:Wait, 20],
          [:PlaySoundEvent, 'escape'],
          [:Wait, 20],
          [:ShowText, "The Red Heracross ran towards the back of the forest!"],
          [:ControlVariable, 694, :[]=, :Constant, 7],
          [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
          [:Wait, 10],
        :Done,
        [:When, 1, "No"],
        :Done)
    }
  }
}

InjectionHelper.defineMapPatch(244, 21, 0) { |page|
  page.patch(:heracrossskip) {
    page.insertBeforeEnd(
      [:ShowText, "Ask her to corral the Heracross for you?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowAnimation, :This, 4], # Question
        [:Wait, 20],
        [:ShowText, "AELITA: What is it?"],
        [:CallCommonEvent, 97], # Player talk
        [:ShowText, "AELITA: Ugh, fine."],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:Wait, 40],
        [:PlaySoundEvent, 'PRSFX- Trainer', 80, 100],
        [:Wait, 20],
        [:PlaySoundEvent, 'escape'],
        [:Wait, 20],
        [:ShowText, "The Red Heracross ran towards the back of the forest!"],
        [:ControlVariable, 694, :[]=, :Constant, 7],
        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
        [:Wait, 10],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
