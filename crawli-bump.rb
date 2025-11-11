class Game_Player
  def playBumpSE
    # unless Reborn
    #   pbSEPlay("bump")
    #   return
    # end

    terrain = Kernel.pbFacingTerrainTag
    event = pbFacingEvent()
    eventName = event.nil? ? "" : event.name
    character = event.nil? ? "" : event.character_name
    eventHasCommands = event.nil? || event.list.nil? ? false : event.list.length > 1

    # check events
    # npcs
    return pbAccessibilitySEPlay("bump-npc") if character.start_with?("trchar") || character.start_with?("NPC ") || character.start_with?("rby_char")
    # overworld pokemon
    return pbAccessibilitySEPlay("bump-pkmn") if character.start_with?("pkmn_")
    # berry tree
    return pbAccessibilitySEPlay("bump-berrytree") if character.start_with?("berrytree")
    # chess pieces, Agate Gym and VR tuners, Mirage Tower controllers/receivers
    return pbAccessibilitySEPlay("bump-block") if character.start_with?("chess") || eventName.start_with?("Tuner ") || eventName.start_with?("2Tuner ") || eventName.start_with?("Controller") || eventName.start_with?("Receiver")
    # cut tree
    return pbAccessibilitySEPlay("bump-cut") if eventName == "Tree"
    # headbutt tree
    return pbAccessibilitySEPlay("bump-headbutt") if eventName == "HeadbuttTree"
    # rock smash rock
    return pbAccessibilitySEPlay("bump-rocksmash") if eventName == "Rock"
    # breakable mirrors
    return pbAccessibilitySEPlay("bump-mirror") if eventName == "Glass"
    # zygarde cells
    return pbAccessibilitySEPlay("bump-zcell") if character == "Object Cell"
    # item balls
    return pbAccessibilitySEPlay("bump-item") if character.start_with?("Object ball")
    # rock climb check names? found one in celestine that's wrong
    return pbAccessibilitySEPlay("bump-rockclimb") if eventName.start_with?("RockClimb") && eventHasCommands
    # check terrains
    return pbAccessibilitySEPlay("bump-water") if pbIsJustWaterTag?(terrain)
    # check terrains
    return pbAccessibilitySEPlay("bump-lava") if pbIsLavaTag?(terrain)
    # bad water
    return pbAccessibilitySEPlay("bump-grime") if pbIsGrimeTag?(terrain)
    # waterfall
    return pbAccessibilitySEPlay("bump-waterfall") if terrain == PBTerrain::WaterfallCrest || terrain == PBTerrain::Waterfall
    # ledge
    return pbAccessibilitySEPlay("bump-ledge") if terrain == PBTerrain::Ledge

    # strength rocks handled in pbPushThisBoulder

    pbSEPlay("bump")
  end
end

class Interpreter
  def pbPushThisBoulder
    if $PokemonMap.strengthUsed && pbPushThisEvent
      pbAccessibilitySEPlay("strengthpush")
      return true
    end
    pbAccessibilitySEPlay("bump-strength")
    return false
  end
end