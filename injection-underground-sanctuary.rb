InjectionHelper.defineMapPatch(551, 104) { |event|
  event.patch(:addskip) { |page|
    page.insertBeforeEnd(
      [:ConditionalBranch, :Switch, 1164, false],
        [:ShowText, "Oh, you're blind? I think I can help..."],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ShowText, "ANASTASIA: O-Okay!"],
          [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
          [:PlaySoundEvent, 'Exit Door', 100, 100],
          [:Wait, 10],
          [:ControlSwitch, 1164, true],
            [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
          [:Wait, 10],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "ANASTASIA: O-Okay..."],
        :Done,
      :Done)
  }
}

def patchmaid_underground_sanctuary(event, switch)
  instructions = [
    [:ConditionalBranch, :Switch, switch, false],
      [:ShowText, "And yet, why... Why did Master Indriad order me to assist you?!"],
      [:ShowText, "Will you make me debase myself so?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:ShowText, "So be it."],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:PlaySoundEvent, 'Exit Door', 100, 100],
        [:Wait, 10],
        [:ControlSwitch, switch, true],
        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
        [:Wait, 10],
      :Done,
      [:When, 1, "No"],
      :Done,
    :Done
  ]

  event.pages[0].patch(:addskip) { |page|
    matched = page.lookForSequence([:ControlSelfSwitch, "A", true])
    if matched
      page.insertAfter(matched, *instructions)
    end
  }
  event.pages[1].patch(:addskip) { |page|
    page.insertBeforeEnd(*instructions)
  }
end

InjectionHelper.defineMapPatch(551, 104) { |event|
  patchmaid_underground_sanctuary(event, 1165)
}

InjectionHelper.defineMapPatch(551, 96) { |event|
  patchmaid_underground_sanctuary(event, 1166)
}

InjectionHelper.defineMapPatch(551, 97, 1) { |page|
  page.insertBeforeEnd(
    [:ConditionalBranch, :Switch, 1167, false],
      [:ShowText, "Accessibility? Hah. That is not my place."],
    :Done)
}

InjectionHelper.defineMapPatch(551, 98) { |event|
  patchmaid_underground_sanctuary(event, 1167)
}
