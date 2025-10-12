InjectionHelper.defineMapPatch(250, 38, 3) { |page|
  page.patch(:addpuzzleskip) {
    matched = page.lookForSequence([:ControlVariable, 246, :[]=, :Constant, 31])

    if matched
      page.insertBefore(matched, 
        [:ShowText, "Master Vitus does require me to provide accessibility services, though."],
        [:ShowText, "Shall I arrange the statues for you?"],
        [:ShowText, "VENAM: Seriously?"],
        [:ShowText, "MAID: Quite. Do you wish me to?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ScreenFlash, Color.new(255,255,255,255), 10],
          [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
          [:ControlVariable, 661, :[]=, :Constant, 2],
          [:ControlVariable, 662, :[]=, :Constant, 2],
          [:ControlVariable, 663, :[]=, :Constant, 4],
          [:ControlVariable, 664, :[]=, :Constant, 4],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "MAID: Very well."],
        :Done)
    end
  }
}

InjectionHelper.defineMapPatch(250, 38, 4) { |page|
  page.patch(:addpuzzleskip) {
    page.insertBeforeEnd(
      [:ConditionalBranch, :Variable, 246, :Constant, 32, :<],
        [:ShowText, "Master Vitus does require me to provide accessibility services, though."],
        [:ShowText, "Shall I arrange the statues for you?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ScreenFlash, Color.new(255,255,255,255), 10],
          [:PlaySoundEvent, 'SFX- GBC Teleport', 80, 100],
          [:ControlVariable, 661, :[]=, :Constant, 2],
          [:ControlVariable, 662, :[]=, :Constant, 2],
          [:ControlVariable, 663, :[]=, :Constant, 4],
          [:ControlVariable, 664, :[]=, :Constant, 4],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "MAID: Very well."],
        :Done,
      :Done)
  }
}

InjectionHelper.defineMapPatch(250, 38, 0) { |page|
  page.patch(:addpuzzleskip) {
    page.insertBeforeEnd(
      [:ConditionalBranch, :SelfSwitch, 'A', false],
        [:ShowText, "Actually, I have a note here."],
        [:ShowText, "It says \"If \\PN comes through, solve the puzzle like so.\""],
        [:ShowText, "When the heck did Saki sneak this onto me?"],
        [:ShowText, "I... guess I can do that?"],
        [:ControlSelfSwitch, 'A', true],
      :Done,
      [:ShowText, "Want me to solve it for you?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:Wait, 10],
        [:CallCommonEvent, 36], # Cinematic Scene
        [:Wait, 10],
        [:ControlVariable, 468, :[]=, :Character, :Player, :x],
        [:ControlVariable, 467, :[]=, :Constant, 111],
        [:ControlVariable, 469, :[]=, :Character, :Player, :y],
        [:ChangeScreenColorTone, Color.new(-34,-34,-34,0), 10],
        [:Wait, 10],
        [:PlaySoundEvent, 'PRSFX- Fire Punch1'],
        [:ShowAnimation, 64, 61],
        [:SetMoveRoute, 64, [false,
          [:SetCharacter, "object_chest_1", 0, :Down, 0],
          :Done]],
        :WaitForMovement,
        [:Wait, 20],
        [:ChangeScreenColorTone, Color.new(-255,-255,-255,0), 10],
        [:Wait, 10],
        [:ChangeTransparentFlag, 0],
        [:CallCommonEvent, 44],
        [:ControlVariable, 703, :[]=, :Constant, 6],
        [:TransferPlayer, :Variable, :PlayerMapLocation, :PlayerPositionX, :PlayerPositionY, :Up, false],
        [:ChangeScreenColorTone, Color.new(-34,-34,-34,0), 10],
        [:Wait, 10],
      :Done,
      [:When, 1, "No"],
        [:ShowText, "Well, alright then."],
      :Done)
  }
}
