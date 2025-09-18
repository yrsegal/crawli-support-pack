class PokemonEntry
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(helptext, minlength, maxlength, initialText, mode = -1, pokemon = nil)
    tts(helptext) ### MODDED
    @scene.pbStartScene(helptext, minlength, maxlength, initialText, mode, pokemon)
    ret = @scene.pbEntry
    @scene.pbEndScene
    return ret
  end
end

def pbEnterText(helptext, minlength, maxlength, initialText = "", mode = 0, pokemon = nil)
  tts(helptext) ### MODDED
  ret = ""
  pbFadeOutIn(99999) {
    sscene = PokemonEntryScene.new
    sscreen = PokemonEntry.new(sscene)
    ret = sscreen.pbStartScreen(helptext, minlength, maxlength, initialText, mode, pokemon)
  }
  return ret
end
