class LocationWindow
  alias :crawlisignposts_old_initialize :initialize

  def initialize(name)
    crawlisignposts_old_initialize(name)
    tts(toUnformattedText(name))
  end
end
