InjectionHelper.defineMapPatch(616) { |map|
  map.fillArea(3, 7,
    ["                                  AA  A         ",
     "            BBBBBBBBBBBBBBBBBBBB  A A A         ",
     "            B  B                  AA AA         ",
     "            BBBB                    A           ",
     "                                    A          B",
     "                                    A          B",
     "            AAAA                    A          B",
     "                                    A          B",
     "                                               B",
     "                                               B",
     "                                               B",
     "                                               B",
     "         BB                          A         B",
     "         BB                         BA         B",
     "         BB                         AA         B",
     "         BB                 B     AA A         B",
     "         BB                       A BA         B",
     "         BB    BB   BB             AAA         B",
     "         BB                       A AA   B      ",
     "         BB                       AAAA   B      ",
     "         BB                       ABAA   B      ",
     "         BB                       AAAA   B      ",
     "         BB   BBBBBBBBB     B            B      ",
     "         BB                              B      ",
     "         BB       B                      B      ",
     "          B       B                      B      ",
     "         BB       B                      B      ",
     "         B                               B      ",
     "         B                               B      ",
     "         B                               B      ",
     "         B                               B      ",
     "         B                               B      ",
     "         B           BBBBB               B      ",
     "         B           BBBBB        BBBBBBBB      ",
     "         B            B BB        BBBBBBBB      ",
     "BB       B           BBBBB               B      ",
     "         B           BBBBB             B B      ",
     "         B           BBBBB             B B      ",
     "         B                               B      ",
     "                                                ",
     "                                                ",
     "                                                ",
     "                                                ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             ",
     "                  B                             "],
    {
      "A" => [1298, nil, nil],
      "B" => [1296, nil, nil],
    })

  electricDamageEvents = [1, 2, 3, 4, 8, 9, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 65, 66, 67, 71, 100, 101, 102]
  poisonDamageEvents = [10, 23, 24, 29]
  teleportEvents = [11, 12, 28, 32, 41, 110]
  autoShutOffEvents = [27, 30, 33, 40, 42]

  for evtid in electricDamageEvents + poisonDamageEvents + teleportEvents + autoShutOffEvents
    map.events[evtid].patch(:eventiskill) { |page|
      page.autorun(:EraseEvent)
    }
  end
}
