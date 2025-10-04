BLACKSTEEPLE_ROBOTS = [[31, 53, 76], [32, 67, 69], [35, 78, 69]]

BLACKSTEEPLE_ROBOTS.each { |robot, targetX, targetY|
  InjectionHelper.defineMapPatch(443, robot) { |event|
    event.patch(:blacksteeplerobots) { |page|
      matched = page.lookForAll([:ControlSelfSwitch, 'A', true])

      for insn in matched
        page.insertAfter(insn, 
          [:ShowText, "(Do you want to automatically move the robot to the correct location?)"],
          [:ShowChoices, ["Yes", "No"], 2],
          [:When, 0, "Yes"],
            [:SetEventLocation, :This, :Constant, targetX, targetY, :Down],
          :Done,
          [:When, 1, "No"],
          :Done)
      end
    }
  }
}

InjectionHelper.defineMapPatch(443, 107) { |event|
  event.patch(:blacksteeplerobotreset) { |page|
    choices = page.lookForSequence(
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
      [:When, 1, "No"],
      :BranchEndChoices)

    if choices
      choices[0].parameters[0].push("Skip Puzzle")
      page.insertBefore(choices[3],
        [:When, 2, "Skip Puzzle"],
          [:ShowText, "Do you want to skip this puzzle completely?"],
          [:ShowChoices, ["No", "Yes"], 1],
          [:When, 0, "No"],
          :Done,
          [:When, 1, "Yes"],
            *BLACKSTEEPLE_ROBOTS.map { |robot, targetX, targetY| [:SetEventLocation, robot, :Constant, targetX, targetY, :Down] },
          :Done,
        :Done)
    end
  }
}
