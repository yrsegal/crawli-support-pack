InjectionHelper.defineMapPatch(438) { |map| # Blacksteeple Stealth
  map.createNewEvent(22, 49, "Accessibility Option") { |event|
    event.newPage { |page|
      page.requiresVariable(232, 64) # Blacksteeple Story
      page.requiresSwitch(1291) # Force Night

      page.playerTouch(
        [:ShowAnimation, :Player, EXCLAMATION_ANIMATION_ID],
        [:ShowText, "EMMA: Oh, right!"],
        [:ShowText, "I wanted to prepare in case I brought \\v[12] along, so I planted a bomb..."],
        [:ShowText, "Wait, that sounds bad. It's just noise and light. I think."],
        [:ShowText, "I just need it to distract the guards."],
        [:ShowAnimation, :Player, 16], # Ellipsis
        [:Wait, 30],
        [:ShowText, "EMMA: Should I activate it anyway?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ScreenFlash, Color.new(255,255,255,255), 10],
          [:PlaySoundEvent, 'Explosion2', 80, 70],
          [:ScreenShake, 8, 8, 20],
          [:Wait, 30],
          [:ControlSelfSwitch, 'B', true],
          [:Script, "(73..77).each { |i| pbSetSelfSwitch(i,'A',true) }"],
          [:ShowAnimation, :Player, 16], # Ellipsis
          [:Wait, 30],
          [:ShowText, "EMMA: Most of the guards should have run away to see what that was."],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "EMMA: ... I might be fine. If it gets hard, though..."],
          [:ControlSelfSwitch, 'A', true],
          :EraseEvent,
        :Done)
    }

    event.newPage { |page|
      page.requiresVariable(232, 64) # Blacksteeple Story
      page.requiresSwitch(1291) # Force Night
      page.requiresSelfSwitch('A')

      page.playerTouch(
        [:ShowText, "EMMA: Should I activate the bomb to distract the guards?"],
        [:ShowChoices, ["Yes", "No"], 2],
        [:When, 0, "Yes"],
          [:ScreenFlash, Color.new(255,255,255,255), 10],
          [:PlaySoundEvent, 'Explosion2', 80, 70],
          [:ScreenShake, 8, 8, 20],
          [:Wait, 30],
          [:ControlSelfSwitch, 'B', true],
          [:Script, "(73..77).each { |i| pbSetSelfSwitch(i,'A',true) }"],
          [:ShowAnimation, :Player, 16], # Ellipsis
          [:Wait, 30],
          [:ShowText, "EMMA: Most of the guards should have run away to see what that was."],
        :Done,
        [:When, 1, "No"],
          [:ShowText, "EMMA: ... I might be fine. If it gets hard, though..."],
          :EraseEvent,
        :Done)
    }

    event.newPage { |page|
      page.requiresSelfSwitch('B')
    }
  }


  for eventid in 73..77
    map.events[eventid].newPage { |page|
      page.requiresSelfSwitch('A')
    }
  end
}
