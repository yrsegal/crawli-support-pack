InjectionHelper.defineMapPatch(414, 5) { |event|
  event.patch(:sayhype) { |page|
    litMessage = page.lookForSequence([:ShowText, /Once the door is completely lit open/])

    if litMessage
      page.insertBefore(litMessage,
        [:Script, "$game_variables[1] = [550, [0, $game_variables[115]].max].min * 100 / 550"],
        [:ShowText, "It's currently \\v[1]% of the way there!"])
    end
  }
}
