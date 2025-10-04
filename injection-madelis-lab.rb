
class Game_Screen
  attr_accessor :crawli_madelislabskip
end

InjectionHelper.registerScriptSwitch("$game_screen.crawli_madelislabskip")

InjectionHelper.defineMapPatch(124) { |map|
  map.createNewEvent(16, 26, "Accessibility Option") { |event|
    event.newPage { |page|
      page.interact(
        [:ShowText, "Welcome to Madelis' wonderful accessibility services."],
        [:ShowText, "Here to remind you that while we're evil, we're not ableist."],
        [:ShowText, "Would you like to disable the gates in this laboratory?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:PlaySoundEvent, 'PRSFX- Metal Burst2', 80, 100],
          [:Script, "$game_screen.crawli_madelislabskip=true"],
          [:Script, "$game_map.need_refresh=true"],
        :Done,
        [:When, 1, "No"],
        :Done)
    }

    event.newPage { |page|
      page.requiresSwitch(InjectionHelper.getScriptSwitch("$game_screen.crawli_madelislabskip"))
    }
  }
}

InjectionHelper.defineMapPatch(-1) { |map|
  map.events.values.each { |event|
    if event.pages.any? { |it| it.graphic.character_name == "object_madelisgate" || it.graphic.character_name == "object_madelisgate_1" }
      event.newPage { |page|
        page.requiresSwitch(InjectionHelper.getScriptSwitch("$game_screen.crawli_madelislabskip"))
      }
    end
  }
}
