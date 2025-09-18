if System.platform[/Windows/]
  dllloc = File.join(__dir__, 'libTolk.dll')
  if File.exist?(dllloc)
    # Windows Speech API needs to be enabled explicitly. Uncomment this line to do so.
    # Win32API.new('libTolk.dll', 'Tolk_TrySAPI', 'b', 'v').call(true)
    Win32API.new(dllloc, 'Tolk_Load', '', 'v').call()
    tolk = Win32API.new(dllloc, 'Tolk_Speak', ['p', 'b'], 'v')
    $tts = ->(message, interrupt) {
      tolk.call(message.encode('utf-16le'), interrupt)
    }
  else
  dllloc = File.join(__dir__, 'nvdaControllerClient.dll')
    if File.exist?(dllloc)
      nvdaSpeak = Win32API.new(dllloc, 'nvdaController_speakText', 'p', 'v')
      nvdaCancel = Win32API.new(dllloc, 'nvdaController_cancelSpeech', '', 'v')
      $tts = ->(message, interrupt) {
        nvdaCancel.call if interrupt
        nvdaSpeak.call(message.encode('utf-16le'))
      }
    end
  end
elsif System.platform[/Mac/] || System.platform[/macOS/]

  Process.kill(:SIGINT, $TTS_CURRENT_PID) if defined?($TTS_CURRENT_PID) && $TTS_CURRENT_PID != -1
  $TTS_CURRENT_PID = -1
  $tts = ->(message, interrupt) {
    Process.kill(:SIGINT, $TTS_CURRENT_PID) if interrupt && $TTS_CURRENT_PID != -1
    Process.wait($TTS_CURRENT_PID) if !interrupt && $TTS_CURRENT_PID != -1
    $TTS_CURRENT_PID = Process.spawn("say -r 200 --quality 0 #{message.gsub(/["\$\r]/, '').inspect}")
  }
end

def tts(text, interrupt = false)
  return if text == ""

  text = text.to_s if text.instance_of?(Integer)
  unless text.instance_of?(String)
    PBDebug.log('Incorrect tts call: ' + text.class.to_s)
    return
  end
  $tts.call(text.downcase, interrupt) unless $tts.nil?
end
