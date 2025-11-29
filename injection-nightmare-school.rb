InjectionHelper.defineMapPatch(99, 44) { |event|
  event.patch(:speakcolorofbox) { |page|
    matched = page.lookForAll([:ShowText, /Welcome to Build an Employee!/])

    for insn in matched
      page.insertAfter(insn,
        [:ConditionalBranch, :Variable, 685, :Constant, 6, :==],
          [:ShowText, "Our current target is: BLUE."],
        :Else,
          [:ConditionalBranch, :Variable, 685, :Constant, 7, :==],
            [:ShowText, "Our current target is: RED."],
          :Else,
            [:ConditionalBranch, :Variable, 685, :Constant, 8, :==],
              [:ShowText, "Our current target is: GREEN."],
            :Else,
              [:ConditionalBranch, :Variable, 685, :Constant, 9, :==],
                [:ShowText, "Our current target is: YELLOW."],
              :Else,
                [:ShowText, "Our current target is: None! You did it!"],
              :Done,
            :Done,
          :Done,
        :Done)
    end
  }
}

[3, 8, 11, 17].each { |evtid|
  InjectionHelper.defineMapPatch(160, evtid) { |event|
    choices = page.lookForSequence(
      [:ShowText, "Use the terminal?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
      [:When, 1, "No"],
      :BranchEndChoices)

    jumptarget = page.lookForSequence([:PlaySoundEvent, 'SFX - Complete!'])

    if choices && jumptarget
      choices[1].parameters[0].push("Skip Puzzle")
      page.insertBefore(choices[4],
        [:When, 2, "Skip Puzzle"],
          [:ShowText, "Do you want to skip this puzzle completely?"],
          [:ShowChoices, ["No", "Yes"], 1],
          [:When, 0, "No"],
            :ExitEventProcessing,
          :Done,
          [:When, 1, "Yes"],
            [:JumpToLabel, 'skippuzzle'],
          :Done,
        :Done)

      page.insertBefore(jumptarget, [:Label, 'skippuzzle'])
    end
  }
}

InjectionHelper.defineMapPatch(144, 33) { |event|
  event.pages[0].patch(:offerskip) { |page|
    page.insertBeforeEnd(
      [:ShowText, "Would you like to skip pushing Manuela into place?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ControlSelfSwitch, 'A', true],
        [:ShowText, "Manuela is ready to show you the truth as soon as you push her."],
      :Done,
      [:When, 1, "No"],
      :Done)
  }

  for pageid in 1...5
    event.pages[pageid].patch(:skipiftaken) { |page|
      page.insertAtStart(
        [:ConditionalBranch, :SelfSwitch, 'A', true],
          [:ControlVariable, 685, :[]=, :Constant, 45 + pageid * 2],
          :ExitEventProcessing,
        :Done)
    }
  end
}

InjectionHelper.defineMapPatch(33, 13) { |event|
  event.newPage {}
}

InjectionHelper.defineMapPatch(33, 65) { |event|
  event.patch(:informrisastopped) { |page|
    matched = page.lookForSequence([:ControlVariable, 684, :[]=, :Constant, 61])

    if matched
      page.insertAfter(matched, 
        [:ShowText, "SEC: Hey, just so you know, we disabled her running after you."],
        [:ShowText, "This would have been a chase sequence, and it'd have been a whole thing."],
        [:ShowText, "Frankly, this segment bullies sighted players too. I'm doing you a favor."])
    end
  }
}

