
def pbPokemonString(pkmn)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end

  info = []
  info.push pkmn.name
  info.push "Level #{pkmn.level}"

  if pkmn.hp <= 0
    info.push " Status: Fainted"
  else
    case pkmn.status
      when :SLEEP
        info.push " Status: Asleep"
      when :FROZEN
        info.push " Status: Frozen"
      when :BURN
        info.push " Status: Burned"
      when :PARALYSIS
        info.push " Status: Paralyzed"
      when :POISON
        info.push " Status: Poisoned"
    end
  end

  info.push(pkmn.hp == pkmn.totalhp ? "Full Health" : "HP: #{pkmn.hp} out of #{pkmn.totalhp}") if pkmn.hp > 0

  if pkmn.type2.nil?
    info.push "Type: #{getTypeName(pkmn.type1)}"
  else
    info.push "Type: #{getTypeName(pkmn.type1)} / #{getTypeName(pkmn.type2)}"
  end

  info.push "Ability: #{getAbilityName(pkmn.ability)}"
  info.push "Item: #{pkmn.item ? getItemName(pkmn.item) : "None"}"
  info.push "Gender: #{["Male", "Female"][pkmn.gender]}" if pkmn.gender < 2

  return info.join(", ")
end

def pbEnemyPokemonString(pkmn)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end

  status = ""
  if pkmn.hp <= 0
    status = " Status: Fainted"
  else
    case pkmn.status
      when :SLEEP
        status = " Status: Asleep"
      when :FROZEN
        status = " Status: Frozen"
      when :BURN
        status = " Status: Burned"
      when :PARALYSIS
        status = " Status: Paralyzed"
      when :POISON
        status = " Status: Poisoned"
    end
  end
  return "#{pkmn.name} (Level #{pkmn.level})#{status} HP: #{(pkmn.hp.to_f / pkmn.totalhp.to_f * 1000).to_i / 10.0} %"
end

class PokeBattle_Battle
  
  def pbCommandPhase(delay=true)
    pbAceMessage() if @ace_message && !@ace_message_handled && Reborn
    delayedaction if Rejuv && delay == true
    @scene.pbBeginCommandPhase
    @scene.pbResetCommandIndices if $Settings.remember_commands==0 
    ### MODDED/
    tts("Battlers: ")
    for i in 0...4
      tts(pbPokemonString(battlers[i])) if !pbIsEnemy(i)
      tts(pbEnemyPokemonString(battlers[i])) if pbIsEnemy(i)
      break if !@doublebattle && i >= 1
    end
    ### /MODDED
    for i in 0...4   # Reset choices if commands can be shown
      if pbCanShowCommands?(i) || @battlers[i].isFainted?
        @choices[i][0]=0
        @choices[i][1]=0
        @choices[i][2]=nil
        @choices[i][3]=-1
      else
        battler=@battlers[i]
        unless !@doublebattle && pbIsDoubleBattler?(i)
          PBDebug.log("[reusing commands for #{battler.pbThis(true)}]") if $INTERNAL
        end
      end
    end
    for i in 0..3
      @switchedOut[i] = false
    end
    # Reset choices to perform Mega Evolution/Z-Moves/Ultra Burst if it wasn't done somehow
    for i in 0...@megaEvolution[0].length
      @megaEvolution[0][i]=-1 if @megaEvolution[0][i]>=0
    end
    for i in 0...@megaEvolution[1].length
      @megaEvolution[1][i]=-1 if @megaEvolution[1][i]>=0
    end
    for i in 0...@ultraBurst[0].length
      @ultraBurst[0][i]=-1 if @ultraBurst[0][i]>=0
    end
    for i in 0...@ultraBurst[1].length
      @ultraBurst[1][i]=-1 if @ultraBurst[1][i]>=0
    end
    for i in 0...@zMove[0].length
      @zMove[0][i]=-1 if @zMove[0][i]>=0
    end
    for i in 0...@zMove[1].length
      @zMove[1][i]=-1 if @zMove[1][i]>=0
    end
    pbJudge #juuuust in case we don't want to be here
    return if @decision>0
    @commandphase=true
    for i in 0...4
      break if @decision!=0
      next if @choices[i][0]!=0
      #AI CHANGES
      if !pbOwnedByPlayer?(i) || @controlPlayer || @battlers[i].issossmon
        next
      end
      commandDone=false
      commandEnd=false
      if pbCanShowCommands?(i)
        loop do
          cmd=pbCommandMenu(i)
          if cmd==0 # Fight
            if pbCanShowFightMenu?(i)
              commandDone=true if pbAutoFightMenu(i)
              until commandDone
                index=@scene.pbFightMenu(i)
                if index<0
                  side=(pbIsOpposing?(i)) ? 1 : 0
                  owner=pbGetOwnerIndex(i)
                  if @megaEvolution[side][owner]==i
                    @megaEvolution[side][owner]=-1
                  end
                  if @ultraBurst[side][owner]==i
                    @ultraBurst[side][owner]=-1
                  end
                  if @zMove[side][owner]==i
                    @zMove[side][owner]=-1
                  end
                  break
                end
                if !pbRegisterMove(i,index)
                  @zMove[0][0]=-1 if @zMove[0][0]>=0
                  @zMove[1][0]=-1 if @zMove[1][0]>=0
                  next
                end
                if @doublebattle
                  side=(pbIsOpposing?(i)) ? 1 : 0
                  owner=pbGetOwnerIndex(i)
                  basemove= @zMove[side][owner]==i ? basemove=@battlers[i].zmoves[index] : basemove=@battlers[i].moves[index]
                  target=@battlers[i].pbTarget(basemove)
                  if target==:SingleNonUser # single non-user
                    target=@scene.pbChooseTarget(i)
                    if target<0
                      @zMove[0][0]=-1 if @zMove[0][0]==i
                      @zMove[1][0]=-1 if @zMove[1][0]==i
                      next
                    end
                    pbRegisterTarget(i,target)
                  elsif target==:UserOrPartner # Acupressure
                    target=@scene.pbChooseTargetAcupressure(i)
                    if target<0 || (target&1)!=(i&1)
                      @zMove[0][0]=-1 if @zMove[0][0]==i
                      @zMove[1][0]=-1 if @zMove[1][0]==i
                      next
                    end
                    pbRegisterTarget(i,target)
                  end
                end
                commandDone=true
              end
            else
              commandDone=pbAutoChooseMove(i)
            end
          elsif cmd==1 # Bag
            if !@internalbattle
              if pbOwnedByPlayer?(i)
                pbDisplay(_INTL("Items can't be used here."))
              end
            elsif @battlers[i].effects[:SkyDrop]
              pbDisplay(_INTL("Sky Drop won't let {1} go!",@battlers[i].name))
            else
              item=pbItemMenu(i)
              if item[0]
                if pbRegisterItem(i,item[0],item[1])
                  commandDone=true
                end
              end
            end
          elsif cmd==2 # Pokémon
            pkmn=pbSwitchPlayer(i,false,true)
            if pkmn>=0
              commandDone=true if pbRegisterSwitch(i,pkmn)
            end
          elsif cmd==3   # Run
            run=pbRun(i)
            if run>0
              commandDone=true
              return
            elsif run<0
              commandDone=true
              side=(pbIsOpposing?(i)) ? 1 : 0
              owner=pbGetOwnerIndex(i)
              if @megaEvolution[side][owner]==i
                @megaEvolution[side][owner]=-1
              end
              if @ultraBurst[side][owner]==i
                @ultraBurst[side][owner]=-1
              end
              if @zMove[side][owner]==i
                @zMove[side][owner]=-1
              end
            end
          elsif cmd==4   # Call
            thispkmn=@battlers[i]
            @choices[i][0]=4   # "Call Pokémon"
            @choices[i][1]=0
            @choices[i][2]=nil
            side=(pbIsOpposing?(i)) ? 1 : 0
            owner=pbGetOwnerIndex(i)
            if @megaEvolution[side][owner]==i
              @megaEvolution[side][owner]=-1
            end
            if @ultraBurst[side][owner]==i
              @ultraBurst[side][owner]=-1
            end
            if @zMove[side][owner]==i
              @zMove[side][owner]=-1
            end
            commandDone=true
          elsif cmd==-1   # Go back to first battler's choice
            @megaEvolution[0][0]=-1 if @megaEvolution[0][0]>=0
            @megaEvolution[1][0]=-1 if @megaEvolution[1][0]>=0
            @ultraBurst[0][0]=-1 if @ultraBurst[0][0]>=0
            @ultraBurst[1][0]=-1 if @ultraBurst[1][0]>=0
            @zMove[0][0]=-1 if @zMove[0][0]>=0
            @zMove[1][0]=-1 if @zMove[1][0]>=0
            # Restore the item the player's first Pokémon was due to use
            if @choices[0][0]==3 && $PokemonBag && $PokemonBag.pbCanStore?(@choices[0][1])
              $PokemonBag.pbStoreItem(@choices[0][1])
            end
            pbCommandPhase(false)
            return
          end
          break if commandDone
        end
      end
    end
    @scene.pbChooseEnemyCommand if !isOnline?
    #AI Data collection perry
    for i in 0...4
      $ai_log_data[i].logAIScorings() if !isOnline? && @battlers[i].hp > 0 && !pbOwnedByPlayer?(i)
    end
    if $game_variables[:LuckShinies] != 0
      for battler in @battlers
        if self.pbIsWild? && [1,3].include?(battler.index) && !battler.isFainted? && battler.pokemon.isShiny? && !battler.isbossmon && !battler.issossmon && !@decision==4
          if pbRandom(100)<10
            pbSEPlay("escape",100)
            pbDisplay(_INTL("{1} fled!",battler.name))
            @decision=3
            PBDebug.log("Wild Pokemon Escaped") if $INTERNAL
          end
        end
      end
    end
    @commandphase=false
  end
end

class PokeBattle_Scene

  def pbDisplayMessage(msg, brief = false)
    # Display old message
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)

    # Set new message
    tts(msg) ### MODDED
    cw = @sprites["messagewindow"]
    cw.text = msg
    i = 0
    loop do
      pbGraphicsUpdate
      Input.update
      cw.update
      if i == 40
        cw.text = ""
        cw.visible = false
        return
      end
      if Input.trigger?(Input::C)
        if cw.pausing?
          pbPlayDecisionSE()
          cw.resume
        end
      end
      if !cw.busy?
        if brief
          @briefmessage = true
          20.times do
            pbGraphicsUpdate
            Input.update
          end
          return
        end
        i += 1
      end
    end
  end

  def pbDisplayPausedMessage(msg)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    tts(msg) ### MODDED
    if @messagemode
      @switchscreen.pbDisplay(msg)
      return
    end
    cw = @sprites["messagewindow"]
    cw.text = _ISPRINTF("{1:s}\1", msg)
    loop do
      pbGraphicsUpdate
      Input.update
      if Input.trigger?(Input::C)
        if cw.busy?
          pbPlayDecisionSE() if cw.pausing?
          cw.resume
        elsif !inPartyAnimation?
          cw.text = ""
          pbPlayDecisionSE()
          cw.visible = false if @messagemode
          return
        end
      end
      cw.update
    end
  end

  def pbShowCommands(msg, commands, defaultValue)
    pbWaitMessage
    pbRefresh
    tts(msg) ### MODDED
    pbShowWindow(MESSAGEBOX)
    dw = @sprites["messagewindow"]
    dw.text = msg
    cw = Window_CommandPokemon.new(commands)
    cw.x = Graphics.width - cw.width
    cw.y = Graphics.height - cw.height - dw.height
    cw.index = 0
    cw.viewport = @viewport
    pbRefresh
    update_menu = true
    lastread = nil  ### MODDED
    loop do
      cw.visible = !dw.busy?
      pbGraphicsUpdate
      Input.update
      pbFrameUpdate(cw, update_menu)
      update_menu = false
      dw.update
      ### MODDED/
      tts(commands[cw.index]) if commands[cw.index] != lastread
      lastread = commands[cw.index]
      ### /MODDED
      if Input.trigger?(Input::B) && defaultValue >= 0
        update_menu = true
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text = ""
          return defaultValue
        end
      end
      if Input.trigger?(Input::C)
        update_menu = true
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text = ""
          return cw.index
        end
      end
      if Input.trigger?(Input::DOWN)
        update_menu = true
        cw.index = (cw.index + 1) % commands.length
      end
      if Input.trigger?(Input::UP)
        update_menu = true
        cw.index = (cw.index - 1) % commands.length
      end
    end
  end

  def pbCommandMenuEx(index,texts,mode=0)      # Mode: 0 - regular battle
    pbShowWindow(COMMANDBOX)                   #       1 - Shadow Pokémon battle
    cw=@sprites["commandwindow"]               #       2 - Safari Zone
    cw.setTexts(texts)                         #       3 - Bug Catching Contest
    cw.index=0 if @lastcmd[index]==2
    cw.mode=mode
    pbSelectBattler(index)
    pbRefresh
    update_menu=true
    tts(texts[0]) ### MODDED
    loop do
      pbGraphicsUpdate
      Input.update
      pbFrameUpdate(cw,update_menu)
      update_menu=false
      # Update selected command
      if Input.trigger?(Input::CTRL)
        pbToggleStatsBoostsVisibility
        pbPlayCursorSE()
        update_menu=true
      elsif Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE()
        cw.index-=1
        tts(texts[cw.index + 1]) ### MODDED
        update_menu=true
      elsif Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE()
        cw.index+=1
        tts(texts[cw.index + 1]) ### MODDED
        update_menu=true
      elsif Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE()
        cw.index-=2
        tts(texts[cw.index + 1]) ### MODDED
        update_menu=true
      elsif Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE()
        cw.index+=2
        tts(texts[cw.index + 1]) ### MODDED
        update_menu=true
      end
      if Input.trigger?(Input::C)   # Confirm choice
        pbPlayDecisionSE()
        ret=cw.index
        @lastcmd[index]=ret
        cw.index=0 if $Settings.remember_commands==0
        return ret
      elsif Input.trigger?(Input::B) && index==2 #&& @lastcmd[0]!=2 # Cancel #Commented out for cancelling switches in doubles
        pbPlayDecisionSE()
        return -1
      end
    end
  end

  def pbFightMenu(index)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler=@battle.battlers[index]
    cw.battler=battler
    lastIndex=@lastmove[index]
    if battler.moves[lastIndex]
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    cw.megaButton=0
    cw.megaButton=1 if (@battle.pbCanMegaEvolve?(index) && !@battle.pbCanZMove?(index))
    cw.megaButton=2 if @battle.megaEvolution[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasMega?
    cw.ultraButton=0
    cw.ultraButton=1 if @battle.pbCanUltraBurst?(index)
    cw.ultraButton=2 if @battle.ultraBurst[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasUltra?
    cw.zButton=0 
    cw.zButton=1 if @battle.pbCanZMove?(index)
    #cw.zButton=2 if @battle.zMove[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasZMove?
    pbSelectBattler(index)
    pbRefresh
    update_menu = true
    ttsMove(battler, cw.index, cw.zButton == 2) ### MODDED
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw,update_menu)
      update_menu = false
      # Update selected command
      if Input.trigger?(Input::CTRL)
        pbToggleStatsBoostsVisibility
        pbPlayCursorSE()
        update_menu=true
      elsif Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE() if cw.setIndex(cw.index-1)
        ttsMove(battler, cw.index, cw.zButton == 2) ### MODDED
        update_menu=true
      elsif Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+1)
        ttsMove(battler, cw.index, cw.zButton == 2) ### MODDED
        update_menu=true
      elsif Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE() if cw.setIndex(cw.index-2)
        ttsMove(battler, cw.index, cw.zButton == 2) ### MODDED
        update_menu=true
      elsif Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+2)
        ttsMove(battler, cw.index, cw.zButton == 2) ### MODDED
        update_menu=true
      end
      if Input.trigger?(Input::C)   # Confirm choice
        ret=cw.index
        if cw.zButton==2
          if battler.pbCompatibleZMoveFromMove?(ret,true)
            pbPlayDecisionSE()
            @lastmove[index]=ret
            return ret
          else
            @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",battler.moves[ret].name,getItemName(battler.item)))
            @lastmove[index]=cw.index
            return -1
          end
        else
          pbPlayDecisionSE()
          @lastmove[index]=ret
          return ret
        end
      elsif Input.trigger?(Input::X)   # Use Mega Evolution 
        if @battle.pbCanMegaEvolve?(index) && !pbIsZCrystal?(battler.item)
          if cw.megaButton==2
            tts("Mega Evolution deactivated") ### MODDED
            @battle.pbUnRegisterMegaEvolution(index)
            cw.megaButton=1
            pbPlayCancelSE()
          else
            tts("Mega Evolution activated") ### MODDED
            @battle.pbRegisterMegaEvolution(index)
            cw.megaButton=2
            pbPlayDecisionSE()
          end
        end
          if @battle.pbCanUltraBurst?(index)
            if cw.ultraButton==2
            tts("Ultra Burst deactivated") ### MODDED
              @battle.pbUnRegisterUltraBurst(index)
              cw.ultraButton=1
              pbPlayCancelSE()
            else
            tts("Ultra Burst activated") ### MODDED
              @battle.pbRegisterUltraBurst(index)
              cw.ultraButton=2
              pbPlayDecisionSE()
            end
          end
        if @battle.pbCanZMove?(index)  # Use Z Move
          if cw.zButton==2
            tts("Z-Moves deactivated") ### MODDED
            @battle.pbUnRegisterZMove(index)
            cw.zButton=1
            pbPlayCancelSE()
          else
            tts("Z-Moves activated") ### MODDED
            @battle.pbRegisterZMove(index)
            cw.zButton=2
            pbPlayDecisionSE()
          end
          ttsMove(battler, cw.index, cw.zButton == 2) if battler.zmoves[cw.index] ### MODDED
        end        
        update_menu=true
      elsif Input.trigger?(Input::B)   # Cancel fight menu
        @lastmove[index]=cw.index
        pbPlayCancelSE()
        return -1
      end
    end
  end

  def pbChooseTarget(index)
    pbShowWindow(FIGHTBOX)
    curwindow=pbFirstTarget(index)
    if curwindow==-1
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted? ### MODDED
    loop do
      pbGraphicsUpdate
      Input.update
      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::B)
        pbUpdateSelected(-1)
        return -1
      end
      if curwindow>=0
        if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
          loop do
            newcurwindow=3 if curwindow==0
            newcurwindow=1 if curwindow==3
            newcurwindow=2 if curwindow==1
            newcurwindow=0 if curwindow==2
            curwindow=newcurwindow
            next if curwindow==index
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted? ### MODDED
        elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
          loop do
            newcurwindow=2 if curwindow==0
            newcurwindow=1 if curwindow==2
            newcurwindow=3 if curwindow==1
            newcurwindow=0 if curwindow==3
            curwindow=newcurwindow
            next if curwindow==index
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted? ### MODDED
        end
      end
    end
  end

  def pbChooseTargetAcupressure(index)
    pbShowWindow(FIGHTBOX)
    curwindow=pbAcupressureTarget(index)
    if curwindow==-1
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted? ### MODDED
    loop do
      pbGraphicsUpdate
      Input.update
      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::B)
        pbUpdateSelected(-1)
        return -1
      end
      if curwindow>=0
        if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
          loop do
            newcurwindow=2 if curwindow==0
            newcurwindow=1 if curwindow==3
            newcurwindow=3 if curwindow==1
            newcurwindow=0 if curwindow==2
            curwindow=newcurwindow
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted? ### MODDED
        elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
          loop do
            newcurwindow=2 if curwindow==0
            newcurwindow=0 if curwindow==2
            newcurwindow=3 if curwindow==1
            newcurwindow=1 if curwindow==3
            curwindow=newcurwindow
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted? ### MODDED
        end
      end
    end
  end


  def pbSwitch(index,lax,cancancel)
    party=@battle.pbParty(index)
    partypos=@battle.partyorder
    ret=-1
    # Fade out and hide all sprites
#    visiblesprites=pbFadeOutAndHide(@sprites)
    pbShowWindow(BLANK)
    pbSetMessageMode(true)
    modparty=[]
    for i in 0...6
      modparty.push(party[partypos[i]])
    end
    visiblesprites=pbFadeOutAndHide(@sprites)
    scene=PokemonScreen_Scene.new
    @switchscreen=PokemonScreen.new(scene,modparty)
    tts("Choose a Pokémon.") ### MODDED
    @switchscreen.pbStartScene(_INTL("Choose a Pokémon."),
       @battle.doublebattle && !@battle.fullparty1)
    loop do
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      activecmd=@switchscreen.pbChoosePokemon
      if cancancel && activecmd==-1
        ret=-1
        break
      end
      if activecmd>=0 && !party[partypos[activecmd]].nil?
        commands=[]
        cmdShift=-1
        cmdSummary=-1
        pkmnindex=partypos[activecmd]
        commands[cmdShift=commands.length]=_INTL("Switch In") if !party[pkmnindex].isEgg?
        commands[cmdSummary=commands.length]=_INTL("Summary")
        commands[commands.length]=_INTL("Cancel")
        command=scene.pbShowCommands(_INTL("Do what with {1}?",party[pkmnindex].name),commands)
        if cmdShift>=0 && command==cmdShift
          canswitch = lax ? @battle.pbCanSwitchLax?(index,pkmnindex,true) : @battle.pbCanSwitch?(index,pkmnindex,true)
          if canswitch
            ret=pkmnindex
            break
          end
        elsif cmdSummary>=0 && command==cmdSummary
          scene.pbSummary(activecmd)
        end
      end
    end
    @switchscreen.pbEndScene
    @switchscreen=nil
    pbShowWindow(BLANK)
    pbSetMessageMode(false)
    # back to main battle screen
    pbFadeInAndShow(@sprites,visiblesprites)
    return ret
  end

  def ttsMove(battler, moveIndex, zmove)
    move = zmove && battler.pbCompatibleZMoveFromMove?(moveIndex, true) ? battler.zmoves[moveIndex] : battler.moves[moveIndex]
    name = getMoveName(move.move)
    name = "Z-" + name if zmove && battler.pbCompatibleZMoveFromMove?(moveIndex, true) && move.category == :status && ![:EXTREMEEVOBOOST, :ELYSIANSHIELD, :CHTHONICMALADY, :DOMAINSHIFT].include?(move.move)
    secondtype = move.getSecondaryType(battler)
    secondtypephrase = ""
    ppphrase = ""
    fieldboostphrase = ""
    if !secondtype.nil? && move.move != :FLYINGPRESS && battler.battle.FE == :RAINBOW
      secondtypephrase = sprintf(" and a random")
    elsif !secondtype.nil? && move.move != :FLYINGPRESS && battler.battle.FE == :CRYSTALCAVERN
      secondtypephrase = sprintf(" and a crystal")
    elsif !secondtype.nil? && !secondtype.include?(move.pbType(battler))
      for i in 0...secondtype.length
        secondtypephrase = secondtypephrase + sprintf(" and %s", secondtype[i].name)
      end
    end
    if !zmove
      ppphrase = sprintf(", %d out of %d pp left", move.pp, move.totalpp)
    end
    fm = @sprites["fightwindow"]
    if fm && fm.buttons
      if fm.buttons.pbFieldNotesBattle(move) == 1
        fieldboostphrase = ", field-boosted"
      elsif fm.buttons.pbFieldNotesBattle(move) == 2
        fieldboostphrase = ", field-diminished"
      end
    end
    tts(sprintf("%s, %s%s type%s%s", name, move.pbType(battler).name, secondtypephrase, ppphrase, fieldboostphrase))
  end
end

class FightMenuDisplay
  attr_reader :buttons

  def initialize(battler,viewport=nil)
    @display=nil
    if PBScene::USEFIGHTBOX
      @display=IconSprite.new(0,Graphics.height-96,viewport)
      @display.setBitmap("Graphics/Pictures/Battle/battleFight")
    end
    @window=Window_CommandPokemon.newWithSize([],0,Graphics.height-96,320,96,viewport, tts: false) ### MODDED
    @window.columns=2
    @window.columnSpacing=4
    @window.ignore_input=true
    pbSetNarrowFont(@window.contents)
    @info=Window_AdvancedTextPokemon.newWithSize(
       "",320,Graphics.height-96,Graphics.width-320,96,viewport)
    pbSetNarrowFont(@info.contents)
    @ctag=shadowctag(PBScene::MENUBASE,
                     PBScene::MENUSHADOW)
    @buttons=nil
    @battler=battler
    @index=0
    @megaButton=0 # 0=don't show, 1=show, 2=pressed
    @ultraButton=0 # 0=don't show, 1=show, 2=pressed
    @zButton=0    # 0=don't show, 1=show, 2=pressed
    if PBScene::USEFIGHTBOX
      @window.opacity=0
      @window.x=Graphics.width
      @info.opacity=0
      @info.x=Graphics.width+Graphics.width-96
      @buttons=FightMenuButtons.new(self.index,nil,viewport)
    end
    refresh
  end
end
