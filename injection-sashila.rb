InjectionHelper.defineMapPatch(516) { |map|
  for evt in [6,7,9,14,15,16,49,50,61,62]
    map.events[evt].patch(:eventiskill) { |page|
      page.autorun(:EraseEvent)
    }
  end

  map.fillArea(41, 43,
    ["                             AAA",
     "                            BCDD",
     "            EC              ACCD",
     "            AFC             DCCD",
     " AA AA      DFC              CC ",
     "AAGHIAA     ACC              CC ",
     "AAJKJAA      CC              AA ",
     "AALMLAA                         ",
     "ACCCCCA                         ",
     " AAAAA                          "],
    {
      "A" => [nil, nil, 0],
      "B" => [2923, nil, 0],
      "C" => [nil, 0, 0],
      "D" => [nil, 0, nil],
      "E" => [nil, nil, 2756],
      "F" => [2923, 0, 0],
      "G" => [2931, nil, 0],
      "H" => [2932, nil, nil],
      "I" => [2933, nil, 0],
      "J" => [116, 0, nil],
      "K" => [116, 0, 0],
      "L" => [96, 0, nil],
      "M" => [96, 0, 0],
    })
}
