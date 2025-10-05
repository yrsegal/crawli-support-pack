
class Game_Screen
  attr_accessor :crawli_labyrinthnosteplimit
end


InjectionHelper.defineMapPatch(535, 1) { |event|
  event.patch(:zorrialynlabyrinthoffertoskip) { |page|
    matched = page.lookForAll([:ControlVariable, :LabStepLimit, :Set, :Constant, nil])
    for insn in matched
      page.insertBefore(insn,
        [:ShowText, "Would you like to disable the step limit for this attempt?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:Script, "$game_screen.crawli_labyrinthnosteplimit = true"],
          [:ShowText, "Press [A] in the labyrinth to escape."],
        :Done,
        [:When, 1, "No"],
          [:Script, "$game_screen.crawli_labyrinthnosteplimit = false"],
        :Done)
    end
  }
}


[533,536,537,541].each { |i|
  InjectionHelper.defineMapPatch(i) { |map|
    map.createSinglePageEvent(10, 0, "Escape option") { |page|
      page.runInParallel(
        [:Wait, 1],
        [:Wait, 1],
        [:ConditionalBranch, :Switch, 1073, false],
          [:ConditionalBranch, :Button, Input::X],
            [:ShowText, "Would you like to escape from the Zorrialyn Labyrinth?"],
            [:ShowChoices, ["No", "Yes"], 1],
            [:When, 0, "No"],
            :Done,
            [:When, 1, "Yes"],
              [:ControlSwitch, 1073, true],
            :Done,
          :Done,
        :Done)
    }
  }
}

Events.onStepTaken+=proc{
  if $game_variables[:LabStepLimit] > 0 && $game_screen.crawli_labyrinthnosteplimit
    $game_variables[:LabStepLimit]+=1
  end
}
