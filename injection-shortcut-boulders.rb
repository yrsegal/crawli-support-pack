def crawli_handle_shortcut_boulders(map, rock, boulder, tile)
  map.events[rock].patch(:killtheboulder) { |page|
    matched = page.lookForAll([:ControlSelfSwitch, "A", true])

    for insn in matched
      page.insertAfter(insn, [:Script, "pbSetSelfSwitch(#{boulder},'A',true)"])
    end
  }
  map.events[boulder].patch(:theboulderisunsure) { |page|
    if page.graphic.character_name == "Object boulder"
      page.graphic.character_name = ""
      page.setTile(tile)
      page.interact()
    end
  }
  map.events[boulder].name = "Obstruction"
  map.events[boulder].newPage { |page| page.requiresSelfSwitch("A") }
end

# Alamissa
InjectionHelper.defineMapPatch(518) { |map|
  for rock, boulder in [[62, 7], [10, 9], [8, 49], [11, 12]]
    crawli_handle_shortcut_boulders(map, rock, boulder, 472)
  end
}

# Zone Zero
InjectionHelper.defineMapPatch(573) { |map|
  for rock, boulder in [[62, 7], [10, 9], [8, 49], [11, 12]]
    crawli_handle_shortcut_boulders(map, rock, boulder, 620)
  end
}

