InjectionHelper.defineMapPatch(518) { |map|
  map.fillArea(10, 12,
    ["                  A             KC CK            DA             ",
     "                 AAE           CFC CFC           GAA            ",
     "                 AAE           CF   FC           GAA            ",
     "                 AAC           CC   CC           CAA            ",
     "                 AAC           CC   CC           CAA            ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                  A             KC CK             A             ",
     "                 AAH           CFC CFC           GAA            ",
     "                 AAH           CF   FC           GAA            ",
     "                 AAC           CC   CC           CAA            ",
     "                 AAC           CC   CC            AA            ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                B   C                           ",
     "                               CC   CC                          ",
     "                               CCC CCC                          ",
     "                               CC   CC                          ",
     "                               CC   CC                          ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "                                                                ",
     "     AAH                                                     ICC",
     "     AAH                                                     ICC",
     "     AAC                                                     CCC",
     "     AAC                        A   A                        CBB",
     "                               BJ   JB                        AA",
     "                               BJ   JB                          ",
     "                               BB   BB                          ",
     "A                              BB   BB                          ",
     "A                                                               ",
     "A                                                               ",
     "A                                                               "],
    {
      "A" => [nil, nil, 0],
      "B" => [nil, 0, 0],
      "C" => [nil, 0, nil],
      "D" => [nil, 1045, 0],
      "E" => [nil, 1016, nil],
      "F" => [1184, 0, nil],
      "G" => [nil, 1018, 0],
      "H" => [nil, 1272, nil],
      "I" => [nil, 1274, nil],
      "J" => [1184, 0, 0],
      "K" => [nil, 1281, 0],
    })

  for evt in [47, 48,
              51, 52, 53, 54, 55, 56, 57, 58, 78, 79,
              64, 65, 66, 67, 68, 69,
              81, 82, 87, 88, 89,
              90, 95, 96,
              114, 115,
              157, 158]
    map.events[evt].patch(:eventiskill) { |page|
      page.autorun(:EraseEvent)
    }
  end

  for evt in [14, 97, 98, 127, 136]
    map.events[evt].patch(:nomove) { |page|
      page.setMoveType(:Fixed)
    }
  end
}
