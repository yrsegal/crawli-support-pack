[1, 2, 3].each { |i|
  InjectionHelper.defineMapPatch(365, 21, i) { |page|
    page.patch(:skipdarchlightmirror) {
      page.insertAtStart(
        [:ShowText, "Force the machine to succeed?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:JumpToLabel, 'y'],
        :Done,
        [:When, 1, "No"],
        :Done)
    }
  }
}
