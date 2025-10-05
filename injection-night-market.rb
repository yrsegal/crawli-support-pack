InjectionHelper.defineMapPatch(198, 79) { |map|
  event.patch(:puzzleskip) { |page|
    matched = page.lookForAll([:ShowText, /in the right one\./]) +
              page.lookForAll([:ShowTextContinued, /in the right one\./]) +
              page.lookForAll([:ShowText, /yield some results\?/]) +
              page.lookForAll([:ShowTextContinued, /yield some results\?/]) +

    for insn in matched
      page.insertAfter(insn,
        [:ShowText, "RISA: Or we can just skip this, since you gotta see stuff and all."],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowText, "RISA: Cool, I'll just sign you up for that gang then."],
          [:ControlVariable, 748, :[]=, :Constant, 16],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:PlaySoundEvent, 'Exit Door', 100, 100],
          [:Wait, 10],
          [:TransferPlayer, :Constant, 248, 10, 31, :Up, false],
          [:ChangeScreenColorTone, Tone.new(-14,-14,-14,0), 10],
          [:Wait, 10],
          :ExitEventProcessing,
        :Done,
        [:When, 1, "No"],
          [:ShowText, "RISA: Alright, you go girl!"],
          [:ConditionalBranch, :Switch, 1058, true],
            [:ShowText, "Or guy. Whatever."],
          :Done,
          [:ConditionalBranch, :Switch, 1060, true],
            [:ShowText, "Or enby. Whatever."],
          :Done,
        :Done)
    end
  }
}

InjectionHelper.defineMapPatch(198, 84) { |map|
  event.patch(:puzzleskip) { |page|
    matched = page.lookForAll([:ShowText, /Just do these steps in order\./]) +
              page.lookForAll([:ShowTextContinued, /Just do these steps in order\./])
    for insn in matched
      page.insertAfter(insn,
        [:ShowText, "But you do have trouble seeing... do you want me to assist?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowText, "RHODEA: Okay, you just have to step like..."],
          [:ControlVariable, 748, :[]=, :Constant, 16],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:PlaySoundEvent, 'Exit Door', 100, 100],
          [:Wait, 10],
          [:TransferPlayer, :Constant, 248, 10, 31, :Up, false],
          [:ChangeScreenColorTone, Tone.new(-14,-14,-14,0), 10],
          [:Wait, 10],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "RHODEA: Sounds good."],
        :Done)
    end
  }
}
