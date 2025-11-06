InjectionHelper.defineMapPatch(401, 7) { |event|

}

InjectionHelper.defineMapPatch(401) { |map|
  cutscene = map.createNewEvent(0, 1, "Cutscene Handler") { |event|
    event.newPage { |page|
      page.requiresSelfSwitch("A")
      page.requiresVariable(403, 0)
      page.autorun(
        [:ControlSwitch, 372, true],
        [:ChangeTransparentFlag, 0],
        [:ControlVariable, 370, :[]=, :Constant, 1],
        [:ControlVariable, 403, :[]=, :Constant, 1],
        [:TransferPlayer, :Constant, 400, 11, 44, :Down, true])
    }
    event.newPage { |page|
      page.requiresSelfSwitch("A")
      page.requiresVariable(403, 2)
      page.autorun(
        [:ControlSwitch, 372, true],
        [:ChangeTransparentFlag, 0],
        [:ControlVariable, 370, :[]=, :Constant, 9],
        [:ControlVariable, 403, :[]=, :Constant, 3],
        [:TransferPlayer, :Constant, 400, 30, 45, :Down, true])
    }
    event.newPage { |page|
      page.requiresSelfSwitch("A")
      page.requiresVariable(403, 4)
      page.autorun(
        [:ControlSwitch, 372, true],
        [:ChangeTransparentFlag, 0],
        [:ControlVariable, 370, :[]=, :Constant, 17],
        [:ControlVariable, 403, :[]=, :Constant, 4],
        [:TransferPlayer, :Constant, 400, 11, 62, :Down, true])
    }
    event.newPage { |page|
      page.requiresVariable(403, 5)
      page.requiresSelfSwitch("A")
      page.autorun(
        [:ControlVariable, 370, :[]=, :Constant, 21],
        [:TransferPlayer, :Constant, 401, 24, 45, :Down, true],
        [:ControlSelfSwitch, "A", false])
    }
  }

  map.events[7].name = "Accessibility Skip"
  map.events[7].patch(:addskip) { |page|
    page.insertBeforeEnd(
      [:ShowText, "I'm kind of fed up with it, though."],
      [:ShowText, "Want to just skip past it?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],

        [:Script, "pbSetSelfSwitch(#{cutscene.id},'A',true)"],
        [:ChangeScreenColorTone, Tone.new(-255,-255,-255,0), 10],
        [:PlaySoundEvent, 'PRSFX- Teleport', 100, 100],
        [:Wait, 12],

        [:ConditionalBranch, :Variable, 273, :Constant, 3, :==],
          [:ControlVariable, 370, :[]=, :Constant, 14],
          [:TransferPlayer, :Constant, 401, 33, 6, :Right, true],
        :Else,
          [:ConditionalBranch, :Variable, 403, :Constant, 0, :==],
            [:ControlSwitch, 372, true],
            [:ChangeTransparentFlag, 0],
            [:ControlVariable, 370, :[]=, :Constant, 1],
            [:ControlVariable, 403, :[]=, :Constant, 1],
            [:TransferPlayer, :Constant, 400, 11, 44, :Down, true],
          :Else,
            [:ConditionalBranch, :Variable, 403, :Constant, 2, :==],
              [:ControlSwitch, 372, true],
              [:ChangeTransparentFlag, 0],
              [:ControlVariable, 370, :[]=, :Constant, 9],
              [:ControlVariable, 403, :[]=, :Constant, 3],
              [:TransferPlayer, :Constant, 400, 30, 45, :Down, true],
            :Else,
              [:ConditionalBranch, :Variable, 403, :Constant, 4, :==],
                [:ControlSwitch, 372, true],
                [:ChangeTransparentFlag, 0],
                [:ControlVariable, 370, :[]=, :Constant, 17],
                [:ControlVariable, 403, :[]=, :Constant, 4],
                [:TransferPlayer, :Constant, 400, 11, 62, :Down, true],
              :Else,
                [:ControlVariable, 370, :[]=, :Constant, 21],
                [:TransferPlayer, :Constant, 401, 24, 45, :Down, true],
              :Done,
            :Done,
          :Done,
        :Done,

        [:ChangeScreenColorTone, Tone.new(0,0,0,0), 10],
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
