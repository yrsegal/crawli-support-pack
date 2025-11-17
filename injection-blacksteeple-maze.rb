InjectionHelper.defineMapPatch(461, 39) { |event| # Blacksteeple Playroom, start timer
  event.patch(:disabletimer) { |page|
    matched = page.lookForSequence([:ControlTimer, 0, 180])

    if matched
      page.replaceRange(matched, matched, 
        [:ShowText, "The following section is normally timed. Disable the timer?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:Script, "pbSetSelfSwitch(32,'A',true)"], # Timer checker
        :Done,
        [:When, 1, "No"],
          [:ControlTimer, 0, 180],
        :Done)
    end
  }
}

InjectionHelper.defineMapPatch(461, 32) { |event| # Blacksteeple Playroom, timer checker
  event.newPage { |page|
    page.requiresSelfSwitch("A")
    page.requiresVariable(456, 60)

    page.runInParallel(
      [:PlayBackgroundMusic, 'Feeling - Far Gone'],
      :Loop,
        [:Wait, 999],
      :Done)
  }
  event.newPage { |page|
    page.requiresSelfSwitch("A")
    page.requiresVariable(456, 66)
  }
  event.newPage { |page|
    page.requiresSelfSwitch("A")
    page.requiresVariable(456, 67)

    page.runInParallel(
      [:PlayBackgroundMusic, 'Feeling - Far Gone'],
      :Loop,
        [:Wait, 999],
      :Done)
  }
}
