InjectionHelper.defineMapPatch(418, 99) { |event|
  event.patch(:karenmoment) { |page|
    matched = page.lookForSequence([:ShowText, /many, many stones\.\.\./]) || 
              page.lookForSequence([:ShowTextContinued, /many, many stones\.\.\./])

    if matched
      page.insertAfter(matched, 
        [:ShowText, "\\sh\\c[7]KARRINA: Oh, please. \\PN is blind! How is that fair?"],
        :MemorizeBackgroundSound,
        [:FadeOutBackgroundMusic, 2],
        [:Wait, 10],
        [:ShowAnimation, 96, 16], # Karen, Ellipsis
        [:Wait, 30],
        [:ShowText, "KAREN: Oh snap, you're right! That's bad! That's like bullying orphans!"],
        [:Wait, 20],
        [:ShowText, "\\sh\\c[7]KARRINA: ARE.\\|\\^"],
        [:ShowText, "\\sh\\c[7]YOU.\\|\\^"],
        [:ShowText, "\\sh\\c[7]SERIOUS?"],
        [:ShowText, "KAREN: Doesn't count if I'm the one who orphaned them, Little Duck!"],
        [:Wait, 20],
        [:ShowText, "KAREN: Alright then, Little Dove. Do you want to skip the part where I pelt you with rocks?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowAnimation, 96, 18], # Karen, Lyrical
          [:ShowText, "KAREN: Okay!"],
          [:ScreenFlash, Color.new(255,255,255,255), 10],
          [:PlaySoundEvent, 'PRSFX- Swift1', 80, 100],
          [:ControlVariable, 265, :[]=, :Constant, 9],
          [:ControlSwitch, 1554, true],
          [:Script, "[146, 61, 101, 62, 120].each {|i| pbSetSelfSwitch(i,'B',true)}"],
          [:ScrollMap, :Down, 27, 6],
          [:Wait, 30],
          [:ShowText, "KARRINA: ...That bitch."],
          :ExitEventProcessing,
        :Done,
        [:When, 1, "No"],
          [:ShowText, "KAREN: Yeah, you're cooler than that."],
        :Done)
    end
  }
}

[146, 61].each {|i|
  InjectionHelper.defineMapPatch(418, i) { |event|
    event.patch(:karenbored) { |page|
      matched = page.lookForSequence([:ShowText, /Best 4 out of 7\?/])

      if matched
        page.insertBefore(matched, 
          [:ConditionalBranch, :SelfSwitch, 'B', true],
            [:ShowText, "KAREN: Well, that was boring."],
            [:JumpToLabel, 'skipinitialtext'],
          :Done)

        idx = page.idxOf(matched)
        while page.size > idx + 1 && page[idx + 1].command == :ShowTextContinued
          idx += 1
        end

        page.insertAfter(idx, [:Label, 'skipinitialtext'])
      end
    }
  }
}

[101, 62, 120].each {|i|
  InjectionHelper.defineMapPatch(418, i) { |event|
    event.newPage { |page|
      page.requiresSelfSwitch("B")
    }
  }
}