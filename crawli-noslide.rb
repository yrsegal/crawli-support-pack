module Kernel
  class << self
    alias crawlinoslide_old_pbSlideOnIce pbSlideOnIce unless method_defined?(:crawlinoslide_old_pbSlideOnIce)
  end

  def self.pbSlideOnIce(event = nil)
    return if BlindstepActive

    crawlinoslide_old_pbSlideOnIce(event)
  end
end
