InjectionHelper.defineMapPatch(120) { |map|
  map.createSinglePageEvent(30, 24, "Accessibility Mareep 1") { |page|
    page.setGraphic("pkmn_mareep")
    page.step_anime = true
    page.move_speed = 1
    page.interact(
      [:PlaySoundEvent, '179Cry', 80, 100],
      [:ShowText, "MAREEP: Baa!"],
      [:ShowText, "It seems to be asking if you want it to eat the electricity ball. What do you say?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, "PRSFX- Bite"],
        [:SetEventLocation, 18, :Constant, 29, 18, :Down],
        [:SetMoveRoute, 18, [false, 
          [:SetCharacter, "", 0, :Down, 0],
          :Done]],
        [:ShowText, "The Mareep is satisfied. It vanished!"],
        :EraseEvent,
      :Done,
      [:When, 1, "No"],
      :Done)
  }
  map.createSinglePageEvent(9, 47, "Accessibility Mareep 2") { |page|
    page.setGraphic("pkmn_mareep")
    page.step_anime = true
    page.move_speed = 1
    page.interact(
      [:PlaySoundEvent, '179Cry', 80, 100],
      [:ShowText, "MAREEP: Baa!"],
      [:ShowText, "It seems to be asking if you want it to eat the electricity balls. What do you say?"],
      [:ShowChoices, ["Yes", "No"], 2],
      [:When, 0, "Yes"],
        [:PlaySoundEvent, "PRSFX- Bite"],
        *[32, 33, 34, 35, 36, 37, 40, 42, 44, 46].flat_map { |it|
          [[:SetEventLocation, it, :Constant, 7, 43, :Down],
           [:SetMoveRoute, it, [false, 
             [:SetCharacter, "", 0, :Down, 0],
             :Done]]]
        },
        [:ShowText, "The Mareep is satisfied. It vanished!"],
        :EraseEvent,
      :Done,
      [:When, 1, "No"],
      :Done)
  }
}
