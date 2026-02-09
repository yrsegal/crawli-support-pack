
InjectionHelper.defineMapPatch(323, 52) { |event|
  event.patch(:blackshardskippuzzle) { |page|
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
            :ExitEventProcessing,
          :Done,
          [:When, 1, "Yes"],
            *[[26, 58, 59, :Left], [53, 62, 62, :Up], [54, 58, 66, :Right], 
              [55, 44, 60, :Up], [61, 50, 61, :Up]].map { |shard, targetX, targetY| 
              [:SetEventLocation, shard, :Constant, targetX, targetY, :Down] 
            },
            [:ConditionalBranch, :Variable, 96, :Constant, 66, :>=],
              [:SetEventLocation, 50, :Constant, 48, 65, :Right],
            :Else,
              [:SetEventLocation, 50, :Constant, 48, 65, :Down],
            :Done,
          :Done,
        :Done)
    end
  }
}
