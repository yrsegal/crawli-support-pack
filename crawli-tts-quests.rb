#===============================================================================
# Class that creates the scrolling list of quest names
#===============================================================================
class Window_Quest

  def quests=(value)
    @quests = value
    Kernel.tts($quest_data.getName(@quests[0].id)) if @quests && @quests[0] ### MODDED
    self.refresh
  end

  def item_changed
    super
    tts($quest_data.getName(@quests[self.index].id)) if @quests
  end
end

#===============================================================================
# Class that controls the UI
#===============================================================================
class QuestList_Scene

  alias :crawlittsquests_old_pbStartScene :pbStartScene
  def pbStartScene
    tts("Active quests")
    crawlittsquests_old_pbStartScene
  end

  alias :crawlittsquests_old_swapQuestType :swapQuestType

  def swapQuestType
    crawlittsquests_old_swapQuestType
    tts(_INTL("{1} tasks", @quests_text[@current_quest]))
  end
  
  def pbQuest(quest)
    quest.notify = false
    drawQuestDesc(quest)
    15.times do
      Graphics.update
      @sprites["overlay2"].opacity += 17; @sprites["overlay3"].opacity += 17; @sprites["page_icon2"].opacity += 17
    end
    page = 1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      showOtherInfo = false
      if Input.trigger?(Input::RIGHT) && page==1
        pbPlayCursorSE
        page += 1
        @sprites["page_icon2"].mirror = true
        drawOtherInfo(quest)
      elsif Input.trigger?(Input::LEFT) && page==2
        pbPlayCursorSE
        page -= 1
        @sprites["page_icon2"].mirror = false
        drawQuestDesc(quest)
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        tts(_INTL("{1} tasks", @quests_text[@current_quest])) ### MODDED
        tts($quest_data.getName(quest.id)) ### MODDED
        break
      end
    end
    15.times do
      Graphics.update
      @sprites["overlay2"].opacity -= 17; @sprites["overlay3"].opacity -= 17; @sprites["page_icon2"].opacity -= 17
    end
    @sprites["page_icon2"].mirror = false
    @sprites["itemlist"].refresh
  end
  
  def drawQuestDesc(quest)
    @sprites["overlay2"].bitmap.clear; @sprites["overlay3"].bitmap.clear
    # Quest name
    questName = $quest_data.getName(quest.id)
    pbDrawTextPositions(@sprites["overlay2"].bitmap,[
      ["#{questName}",6,-2,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    # Quest description
    questDesc = "<c2=#{colorQuest("blue")}>Overview:</c2> <c2=7FDE39CE>#{$quest_data.getQuestDescription(quest.id,quest.stage)}</c2>"
    tts("Overview")
    tts($quest_data.getQuestDescription(quest.id,quest.stage))
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,48,
      436,questDesc,@base,@shadow)
    # Stage description
    questStageDesc = $quest_data.getStageDescription(quest.id,quest.stage)
    # Stage location
    questStageLocation = $quest_data.getStageLocation(quest.id,quest.stage)
    # If 'nil' or missing, set to '???'
    if questStageLocation=="nil" || questStageLocation==""
      questStageLocation = "???"
    end
    drawFormattedTextEx(@sprites["overlay3"].bitmap,36,312,
      436,"<c2=#{colorQuest("orange")}>Task:</c2> <c2=7FDE39CE>#{questStageDesc}</c2>",@base,@shadow)
    tts("Task") ### MODDED
    tts(questStageDesc) ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,341,
      436,"<c2=#{colorQuest("purple")}>Location:</c2> <c2=7FDE39CE>#{questStageLocation}</c2>",@base,@shadow)
    tts("Location") ### MODDED
    tts(questStageLocation) ### MODDED
  end

  def drawOtherInfo(quest)
    @sprites["overlay3"].bitmap.clear
    # Guest giver
    questGiver = $quest_data.getQuestGiver(quest.id)
    # If 'nil' or missing, set to '???'
    questGiver = "???" if questGiver=="nil" || questGiver==""
    # Total number of stages for quest
    questLength = $quest_data.getMaxStagesForQuest(quest.id)
    # Map quest was originally started
    originalMap = quest.location
    # Vary text according to map name
    loc = originalMap.include?("Route") ? "on" : "in"
    # Format time
    time = quest.time.strftime("%B %d %Y %H:%M")
    if getActiveQuests.include?(quest.id)
      time_text = "start"
    elsif getCompletedQuests.include?(quest.id)
      time_text = "completion"
    else
      time_text = "failure"
    end
    # Quest reward
    questReward = $quest_data.getQuestReward(quest.id)
    if questReward=="nil" || questReward==""
      questReward = "???"
    end
    queststage = sprintf("Stage %d/%d",quest.stage,questLength)
    expiration = $quest_data.getQuestTermination(quest.id)
    expiration = "Never!" if expiration=="nil" || expiration==""

    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,44,
      436,"<c2=#{colorQuest("green")}>#{queststage}</c2>",@base,@shadow)
    tts(queststage) ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,84,
      436,"<c2=#{colorQuest("cyan")}>Quest received from:</c2>",@base,@shadow)
    tts("Quest received from:") ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,112,
      436,"<c2=#{colorQuest("green")}>#{questGiver}</c2>",@base,@shadow)
    tts(questGiver) ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,152,
      436,"<c2=#{colorQuest("cyan")}>Quest discovered #{loc}:</c2>",@base,@shadow)
    tts("Quest discovered #{loc}") ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,180,
      436,"<c2=#{colorQuest("green")}>#{originalMap}</c2>",@base,@shadow)
    tts(originalMap) ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,220,
      436,"<c2=#{colorQuest("cyan")}>Quest expiration point:</c2>",@base,@shadow)
    tts("Quest expiration point:") ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,248,
      436,"<c2=#{colorQuest("green")}>#{expiration}</c2>",@base,@shadow)
    tts(expiration) ### MODDED
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,Graphics.height-74,
      436,"<c2=#{colorQuest("orange")}>Reward: </c2><c2=#{colorQuest("red")}>#{questReward}</c2>",@base,@shadow)
    tts("Reward") ### MODDED
    tts(questReward) ### MODDED
  end
end
