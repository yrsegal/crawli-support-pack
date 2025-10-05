[48, 52, 95, 97, 99, 101,
 49].each { |i|
  InjectionHelper.defineMapPatch(456, i) { |event|
    event.newPage {} # Disable the beer glasses and the throw controller in entirety
  }
}

[47, 51, 90, 95, 96, 98, 100].each { |i|
  InjectionHelper.defineMapPatch(456, i) { |event|
    event.patch(:adddialogue) { |page|
      page.insertBeforeEnd(
        [:ShowText, "GRUNT: I'm not gonna throw things at you."],
        [:ShowText, "You're blind. My buddy Jeffery is blind, and he'd kick my ass if I did."])
    }
  }
}
