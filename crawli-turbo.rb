module Input
  unless defined?(crawliturbo_old_update)
    class << Input
      alias :crawliturbo_old_update :update
    end
  end

  def self.update
    turbo = $speed_up

    crawliturbo_old_update
    if BlindstepActive
      # Flips it back off if triggered by any of these
      if triggerex?(:LALT) || (triggerex?(:M) && Input.text_input != true) || triggerex?(:RALT) ||
        # Our actual condition
        (triggerex?(:E) && Input.text_input != true)
        pbTurbo()
      end
    end

    if $speed_up != turbo
      pbAccessibilitySEPlay($speed_up ? "turbo_on" : "turbo_off", 80)
    end
  end
end
