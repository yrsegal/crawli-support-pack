InjectionHelper.defineMapPatch(516) { |map|
  for evt in [6,7,9,14,15,16,49,50,61,62]
    map.events[evt].patch(:eventiskill) { |page|
      page.autorun(:EraseEvent)
    }
  end

  # Doing this in two parts because I am lazy
  map.fillArea(41, 45,
    ["             A               AA",
     "             AA              AA",
     "             AA              AA",
     "             AA              AA",
     "  CDE        AA              BB",
     "BBFGFBB                        ",
     "BAAAAAB                        ",
     " BBBBB                         "],
    {
      "A" => [nil, 0, 0],
      "B" => [nil, nil, 0],
      "C" => [2844, 0, nil],
      "D" => [2923, 0, 0],
      "E" => [2845, 0, nil],
      "F" => [96, 0, nil],
      "G" => [96, 0, 0],
    })
  map.fillArea(41, 43,
    ["                             AAA",
     "                            BCDD",
     "            E               A  D",
     "            AF              D  D",
     " AA AA      DF                  ",
     "AAGHIAA     A                   ",
     "AAJJJAA                         "],
    {
      "A" => [nil, nil, 0],
      "B" => [2923, nil, 0],
      "C" => [nil, 0, 0],
      "D" => [nil, 0, nil],
      "E" => [nil, nil, 2756],
      "F" => [2923, nil, nil],
      "G" => [2931, nil, 0],
      "H" => [2932, nil, nil],
      "I" => [2933, nil, 0],
      "J" => [116, nil, nil],
    })
}
