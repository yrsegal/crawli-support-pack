[[23, [71, 72, 74, 76, 78, 79]],
 [148, [50]],
 [172, [14, 44]]].each { |mapid, evts|
  evts.each { |evtid|
    InjectionHelper.defineMapPatch(mapid, evtid) { |map|
      event.patch(:regicevanish) { |page|
        matched = page.lookForAll([:ControlSwitch, 93, true])

        for insn in matched
          page.insertBefore(insn, [:ControlSelfSwitch, 'A', true])
        end
      }

      event.newPage { |page|
        page.requiresSelfSwitch("A")
      }
    }
  }
}


[16,32,67,73].each { |evtid|
  InjectionHelper.defineMapPatch(395, evtid) { |event|
    event.patch(:laironvanish) { |page|
      matched = page.lookForAll([:ShowAnimation, :This, 42])

      for insn in matched
        page.insertBefore(insn, [:ControlSelfSwitch, 'A', true])
      end
    }
    event.newPage { |page|
      page.requiresSelfSwitch("A")
    }
  }
}
