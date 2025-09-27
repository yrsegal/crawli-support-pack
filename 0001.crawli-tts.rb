if System.platform[/Windows/]
  dllloc = File.join(__dir__[Dir.pwd.length+1..], 'libTolk.dll')
  if File.exist?(dllloc)
    # Windows Speech API needs to be enabled explicitly. Uncomment this line to do so.
    # Win32API.new('libTolk.dll', 'Tolk_TrySAPI', 'b', 'v').call(true)
    Win32API.new(dllloc, 'Tolk_Load', '', 'v').call()
    tolk = Win32API.new(dllloc, 'Tolk_Speak', ['p', 'b'], 'v')
    $tts = ->(message, interrupt) {
      tolk.call(message.encode('utf-16le'), interrupt)
    }
  else
    dllloc = File.join(__dir__[Dir.pwd.length+1..], 'nvdaControllerClient.dll')
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
  # Clean up old pre-reload TTS processes
  Process.kill(:INT, $ACTIVE_TTS_PROCESS) if defined?($ACTIVE_TTS_PROCESS) && $ACTIVE_TTS_PROCESS > 0
  $TTS_THREAD.kill if defined?($TTS_THREAD) && $TTS_THREAD

  # Initialize TTS
  $TTS_QUEUE = []
  $ACTIVE_TTS_PROCESS = -1
  $TTS_THREAD = Thread.new {
    loop do
      if $TTS_QUEUE.empty?
        sleep
      else
        message = $TTS_QUEUE.shift
        $ACTIVE_TTS_PROCESS = spawn "say -r 200 --quality 0 #{message.gsub(/["\$\r\1\2]/, '').inspect}"
        Process.wait($ACTIVE_TTS_PROCESS)
        $ACTIVE_TTS_PROCESS = -1
      end
    end
  }

  $tts = ->(message, interrupt) {
    if interrupt
      $TTS_QUEUE.clear
      Process.kill(:INT, $ACTIVE_TTS_PROCESS) if $ACTIVE_TTS_PROCESS > 0
    end
    
    $TTS_QUEUE.push(message)
    $TTS_THREAD.run
  }

  module Input
    unless defined?(crawlitts_old_update)
      class << Input
        alias :crawlitts_old_update :update
      end
    end

    def self.update
      crawlitts_old_update
      if press?(Input::CTRL)
        $TTS_QUEUE.clear
        Process.kill(:INT, $ACTIVE_TTS_PROCESS) if $ACTIVE_TTS_PROCESS > 0
      end
    end
  end
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
