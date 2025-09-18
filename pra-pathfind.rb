class Game_Player < Game_Character
  alias_method :access_mod_original_update, :update # Make a copy of the original update
  def update
    # First, call the original update method (which includes the running logic)
    access_mod_original_update

    # Then, execute our mod's logic
    # If not moving
    unless moving?
# Cycle event filter (O)
      if Input.triggerex?(0x4F)
        cycle_event_filter(1)
      # Cycle event filter backwards (I)
      elsif Input.triggerex?(0x49)
        cycle_event_filter(-1)
      end

        # Toggle sort by distance (Shift+H)
        if Input.pressex?(0x10) && Input.triggerex?(0x48)
          @sort_by_distance = !@sort_by_distance
          tts("Sort by distance: #{@sort_by_distance ? 'On' : 'Off'}")
      
        # Cycle HM pathfinding toggle (H)
    elsif Input.triggerex?(0x48)
          cycle_hm_toggle
        end

      # Refresh the event list (F5)
      if Input.triggerex?(0x74)
        populate_event_list
        tts('Map list refreshed')
      end

      # Make sure we have events to cycle through
      if !@mapevents.nil? && !@mapevents.empty?
        # Cycle to the PREVIOUS event (J)
        if Input.triggerex?(0x4A)
          @selected_event_index -= 1
          if @selected_event_index < 0
            @selected_event_index = @mapevents.size - 1 # Wrap around
          end
          announce_selected_event
        end

        # Cycle to the NEXT event (L)
        if Input.triggerex?(0x4C)
          @selected_event_index += 1
          if @selected_event_index >= @mapevents.size
            @selected_event_index = 0 # Wrap around
          end
          announce_selected_event
        end

        # Rename selected event (Shift+K)
        if Input.pressex?(0x10) && Input.triggerex?(0x4B)
          rename_selected_event

        # ANNOUNCE the current event (K)
        elsif Input.triggerex?(0x4B)
          announce_selected_event
        end

      # Announce coordinates (Shift+P)
      if Input.pressex?(0x10) && Input.triggerex?(0x50)
        announce_selected_coordinates

        # PATHFIND to the current event (P)
      elsif Input.triggerex?(0x50)
          pathfind_to_selected_event
        end
      end
    end
  end

alias_method :access_mod_original_initialize, :initialize
  def initialize(*args)
    # Call the original initialize method first to set up the player
    access_mod_original_initialize(*args)

    # Now, set up our mod's variables correctly
    @mapevents = []
    @selected_event_index = -1
    @event_filter_modes = [:all, :connections, :npcs, :items, :merchants, :signs, :hidden_items]
    @event_filter_index = 0
    @hm_toggle_modes = [:off, :surf_only, :surf_and_waterfall]
    @hm_toggle_index = 0 # Default to :off
    @sort_by_distance = true # Default to sorting by distance
  end
  
  # --- Helper class and method for finding interactable tiles next to an event ---
  class EventWithRelativeDirection
    attr_accessor :direction, :node
    def initialize(paraNode, paraDirection)
      @direction = paraDirection
      @node = paraNode
    end
  end

  def getEventTiles(event, map = $game_map)
    possibleTiles = []
    if !$MapFactory.isPassable?(map.map_id, event.x, event.y + 1) && $MapFactory.isPassable?(map.map_id, event.x, event.y + 2)
      possibleTiles.push(EventWithRelativeDirection.new(Node.new(event.x, event.y + 2), 2))
    end
    if !$MapFactory.isPassable?(map.map_id, event.x - 1, event.y) && $MapFactory.isPassable?(map.map_id, event.x - 2, event.y)
      possibleTiles.push(EventWithRelativeDirection.new(Node.new(event.x - 2, event.y), 4))
    end
    if !$MapFactory.isPassable?(map.map_id, event.x + 1, event.y) && $MapFactory.isPassable?(map.map_id, event.x + 2, event.y)
      possibleTiles.push(EventWithRelativeDirection.new(Node.new(event.x + 2, event.y), 6))
    end
    if !$MapFactory.isPassable?(map.map_id, event.x, event.y - 1) && $MapFactory.isPassable?(map.map_id, event.x, event.y - 2)
      possibleTiles.push(EventWithRelativeDirection.new(Node.new(event.x, event.y - 2), 8))
    end
    return possibleTiles
  end

def cycle_hm_toggle
  # --- Safeguard for old save files ---
  if @hm_toggle_modes.nil?
    @hm_toggle_modes = [:off, :surf_only, :surf_and_waterfall]
    @hm_toggle_index = 0
  end

  @hm_toggle_index = (@hm_toggle_index + 1) % @hm_toggle_modes.length
  
 
  current_mode = @hm_toggle_modes[@hm_toggle_index]
  announcement = ""
  case current_mode
  when :off
    announcement = "HM pathfinding off"
  when :surf_only
    announcement = "HM pathfinding set to Surf only"
  when :surf_and_waterfall
    announcement = "HM pathfinding set to Surf and Waterfall"
  end
  tts(announcement)
end

def cycle_event_filter(direction = 1)
  # --- Safeguard to initialize variables if they don't exist ---
  if @event_filter_modes.nil?
    # This will run once when loading an old save file
    @event_filter_modes = [:all, :connections, :npcs, :items, :merchants, :signs, :hidden_items]
    @event_filter_index = 0
  end
  
  # Move to the next/previous filter index
  @event_filter_index += direction
  
  # Wrap around if necessary
  if @event_filter_index >= @event_filter_modes.length
    @event_filter_index = 0
  elsif @event_filter_index < 0
    @event_filter_index = @event_filter_modes.length - 1
  end
  
  # Announce the new filter mode
  current_filter = @event_filter_modes[@event_filter_index]
  tts("Filter set to #{current_filter.to_s}")
  
  # Automatically refresh the event list with the new filter
  populate_event_list
end

def rename_selected_event
  # Ensure an event is selected
  return if @selected_event_index < 0 || @mapevents[@selected_event_index].nil?
  event = @mapevents[@selected_event_index]

  # Prompt user for the new name
  new_name = Kernel.pbMessageFreeText(_INTL("Enter new name for the selected event."), "", false, 24)
  
  # Check if the user entered a valid, non-blank name
  if new_name && !new_name.strip.empty?
    # Prompt user for an optional description
    new_desc = Kernel.pbMessageFreeText(_INTL("Enter an optional description."), "", false, 100)

    # Gather all necessary data
    map_id = $game_map.map_id
    map_name = $game_map.name
    x = event.x
    y = event.y

    # Create the unique key and the value hash
    key = "#{map_id};#{x};#{y}"
    value = {
      map_name: map_name,
      event_name: new_name,
      description: new_desc || ""
    }

    # Update the in-memory hash
    $custom_event_names[key] = value
    
    # Save the entire hash back to the file
    save_custom_names
    
    # Provide feedback to the player
    tts("Event renamed to #{new_name}")
  else
    # If the name is blank or the user cancelled, provide feedback
    tts("Event renaming cancelled.")
  end
end

def is_path_passable?(x, y, d)
  # --- Safeguard for old save files ---
  if @hm_toggle_modes.nil?
    @hm_toggle_modes = [:off, :surf_only, :surf_and_waterfall]
    @hm_toggle_index = 0
  end

  # First, check if the tile is normally passable
  return true if passable?(x, y, d)
  
  # If not, check if it's an HM obstacle the player can pass with the toggle
  current_mode = @hm_toggle_modes[@hm_toggle_index]
  return false if current_mode == :off

  # Get the coordinates of the tile we are trying to move to
  new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
  new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
  return false unless self.map.valid?(new_x, new_y)
  
  # Get the terrain tag of the destination tile
  terrain_tag = self.map.terrain_tag(new_x, new_y)

  # Check for Surf
  if pbIsPassableWaterTag?(terrain_tag)
    return true if current_mode == :surf_only || current_mode == :surf_and_waterfall
  end
  
  # Check for Waterfall
  if terrain_tag == PBTerrain::Waterfall || terrain_tag == PBTerrain::WaterfallCrest
    return true if current_mode == :surf_and_waterfall
  end 
  return false
end

def is_sign_event?(event)
  return false if !event || !event.list || !event.character_name.empty?
  for command in event.list
    return true if command.code == 101 # Show Text
  end
  return false
end

def is_merchant_event?(event)
  return false if !event || !event.list
  for command in event.list
    if command.code == 355 && command.parameters[0].is_a?(String)
      return true if command.parameters[0].include?("pbPokemonMart")
    end
  end
  return false
end

def is_item_event?(event)
  return false if !event
  return event.character_name.start_with?("itemball")
end

def is_hidden_item_event?(event)
  return event.name == "HiddenItem"
end

def is_npc_event?(event)
  return false if !event
  # An NPC is any event with a character sprite that isn't a connection or an item.
  return !event.character_name.empty? && 
         !is_teleport_event?(event) && 
         !is_item_event?(event)
end

def is_teleport_event?(event)
  return false if !event || !event.list
  for command in event.list
    # 201 is the event code for "Transfer Player"
    return true if command.code == 201
  end
  return false
end

def get_teleport_destination_name(event)
  return nil if !event || !event.list
  for command in event.list
    if command.code == 201 # Event command for "Transfer Player"
      map_id = command.parameters[1]
      # Use the Map Factory to get the destination map object
      destination_map = $MapFactory.getMap(map_id)
      return destination_map.name if destination_map
    end
  end
  return nil # Return nil if it's not a teleport event
end

def reduceEventsInLanes(eventsArray)
  # This method and its helpers are from the original Malta10 mod.
  eventsInLane = []
  for event in eventsArray
    neighbourNode = getNeighbour(event, eventsArray)
    if neighbourNode != nil
      deleteNodesInOneLane(event, neighbourNode, eventsArray)
    end
  end
end

def getNeighbour(event, eventsArray)
  for currentEvent in eventsArray
    if (event.x - currentEvent.x).abs == 1 && event.y == currentEvent.y || 
       (event.y - currentEvent.y).abs == 1 && event.x == currentEvent.x
      return currentEvent
    end
  end
  return nil
end

def getEvent(x, y, eventsArray)
  for ea in eventsArray
    if ea.x == x && ea.y == y
      return ea
    end
  end
  return nil
end

  def deleteNodesInOneLane(event, neighbourNode, eventsArray)
    nodesInLane = []
    eventDestination = nil
    for eventCommand in event.list
      if eventCommand.code == 201
        eventDestination = eventCommand.parameters[1]
      end
    end
    if event.x == neighbourNode.x #y-axis
      i = 1
      while true
        foundEvent = getEvent(event.x, event.y + i, eventsArray)
        if foundEvent == nil
          break
        end
        for eventCommand in foundEvent.list
          if eventCommand.parameters[1] == eventDestination
            eventsArray.delete(foundEvent)
            break
          end
        end
        i = i + 1
      end
      i = 1
      while true
        foundEvent = getEvent(event.x, event.y - i, eventsArray)
        if foundEvent == nil
          break
        end
        for eventCommand in foundEvent.list
          if eventCommand.parameters[1] == eventDestination
            eventsArray.delete(foundEvent)
            break
          end
        end
        i = i + 1
      end
    else
      #x-axis
      i = 1
      while true
        foundEvent = getEvent(event.x + i, event.y, eventsArray)
        if foundEvent == nil
          break
        end
        for eventCommand in foundEvent.list
          if eventCommand.parameters[1] == eventDestination
            eventsArray.delete(foundEvent)
            break
          end
        end
        i = i + 1
      end
      i = 1
      while true
        foundEvent = getEvent(event.x - i, event.y, eventsArray)
        if foundEvent == nil
          break
        end
        for eventCommand in foundEvent.list
          if eventCommand.parameters[1] == eventDestination
            eventsArray.delete(foundEvent)
            break
          end
        end
        i = i + 1
      end
    end
  end

def announce_selected_coordinates
  return if @selected_event_index < 0 || @mapevents[@selected_event_index].nil?
  event = @mapevents[@selected_event_index]
  
  # Start with the base coordinate announcement
  announcement = "Coordinates: X #{event.x}, Y #{event.y}"
  
  # Create a unique key for the current event
  key = "#{$game_map.map_id};#{event.x};#{event.y}"
  custom_name_data = $custom_event_names[key]
  
  # Check if custom data exists and has a non-empty description
  if custom_name_data && custom_name_data[:description] && !custom_name_data[:description].strip.empty?
    announcement += ". #{custom_name_data[:description]}"
  end
  
  tts(announcement)
end

def announce_selected_event
  return if @selected_event_index == -1 || @mapevents[@selected_event_index].nil?
  event = @mapevents[@selected_event_index]
  dist = distance(@x, @y, event.x, event.y).round

  # Create a unique key for the current event
  key = "#{$game_map.map_id};#{event.x};#{event.y}"
  custom_name_data = $custom_event_names[key]
  announcement_text = ""
  
  # Check if custom name data exists and has a non-empty name
  if custom_name_data && custom_name_data[:event_name] && !custom_name_data[:event_name].strip.empty?
    announcement_text = custom_name_data[:event_name]
    else
  # First, check if the event is a connection.
  if is_teleport_event?(event)
    # If it is, always start the announcement with "Connection to..."
    destination = get_teleport_destination_name(event)
    
    # Use the destination map's name if it's available.
    if destination && !destination.strip.empty?
      announcement_text = "Connection to #{destination}"
    # Otherwise, fall back to the event's own name if it has one.
    elsif event.name && !event.name.strip.empty?
      announcement_text = "Connection to #{event.name}"
    # If neither is available, use a generic announcement.
    else
      announcement_text = "Connection"
    end
  # If it's NOT a connection, check if it has a name.
  elsif event.name && !event.name.strip.empty?
    announcement_text = event.name
  # If all else fails, it's an unnamed interactable object.
  else
    announcement_text = "Interactable object"
  end  
end

  dist = distance(@x, @y, event.x, event.y).round
  facing_direction = ""
  case @direction
  when 2; facing_direction = "facing down"
  when 4; facing_direction = "facing left"
  when 6; facing_direction = "facing right"
  when 8; facing_direction = "facing up"
  end
  
  tts("#{announcement_text}, #{dist} steps away, #{facing_direction}.")
end

def pathfind_to_selected_event
  return if @selected_event_index < 0 || @mapevents[@selected_event_index].nil?
  
  target_event = @mapevents[@selected_event_index]
  
  # First, try to find a direct path to the event's coordinates
  route = aStern(Node.new(@x, @y), Node.new(target_event.x, target_event.y))
  
  # If the direct path fails (e.g., NPC behind a counter)
  if route.empty?
    # Get a list of possible adjacent tiles to interact from
    possible_targets = getEventTiles(target_event)
    
    # Loop through the alternatives and try to find a path to one of them
    for target in possible_targets
      alternative_route = aStern(Node.new(@x, @y), target.node)
      if !alternative_route.empty?
        route = alternative_route # Use the first successful alternative path
        break
      end
    end
  end
  
  # Announce the final route, whether it was direct or an alternative
  printInstruction(convertRouteToInstructions(route))
end

def populate_event_list
  # --- Safeguard to initialize variables if they don't exist ---
  if @event_filter_modes.nil?
    @mapevents = []
    @selected_event_index = -1
    @event_filter_modes = [:all, :connections, :npcs, :items, :merchants, :signs, :hidden_items]
    @event_filter_index = 0
  end

  @mapevents = []
  current_filter = @event_filter_modes[@event_filter_index]

  connections = []
  other_events = []

  for event in $game_map.events.values
    next if !event.list || event.list.size <= 1
    next if event.trigger == 3 || event.trigger == 4 # Ignore Autorun and Parallel

    # Apply the selected filter
    case current_filter
    when :all
      if is_teleport_event?(event)
        connections.push(event)
      else
        other_events.push(event)
      end
    when :connections
      connections.push(event) if is_teleport_event?(event)
    when :npcs
      other_events.push(event) if is_npc_event?(event)
    when :items
      other_events.push(event) if is_item_event?(event)
    when :merchants
      other_events.push(event) if is_merchant_event?(event)
    when :signs
      other_events.push(event) if is_sign_event?(event)
      when :hidden_items  # --- ADD THIS NEW CASE ---
      other_events.push(event) if is_hidden_item_event?(event)
    end
  end
  # Run de-duplication on connections, regardless of filter
  reduceEventsInLanes(connections)

  # Combine the lists and sort
  @mapevents = other_events + connections
# Sort the final list by distance only if the toggle is on
    if @sort_by_distance
      @mapevents.sort! { |a, b| distance(@x, @y, a.x, a.y) <=> distance(@x, @y, b.x, b.y) }
    end
    @selected_event_index = @mapevents.empty? ? -1 : 0
end

  def convertRouteToInstructions(route)
    if route.length == 0
      return []
    end
    instructions = []
    lastNode = Node.new(@x, @y)
    currentDirection = "none"
    # Kernel.pbMessage(route.length.to_s)
    for node in route
      if node == nil
        # Kernel.pbMessage("Node ist nil" + route.to_s)
      else
        #    Kernel.pbMessage("Node ist nicht nil " + node.x.to_s + ", " + node.y.to_s)
      end
      if lastNode == nil
        #Kernel.pbMessage("lastNode ist nil" + route.to_s)
      end
      direction = findRelativeDirection(lastNode, node)
      if (currentDirection == direction)
        instructions[-1].steps = instructions[-1].steps + 1
      else
        instructions.push(Instruction.new(direction))
        currentDirection = direction
      end
      lastNode = node
    end
    return instructions
  end

  def findRelativeDirection(lastNode, node)
    if lastNode.x == node.x
      if lastNode.y < node.y
        return "down"
      else
        return "up"
      end
    else
      if lastNode.x < node.x
        return "right"
      else
        return "left"
      end
    end
    Kernel.pbMessage("Error")
    return "Error"
  end

  def addAdjacentNode(route, direction)
    case direction
    when 2
      route = route.push(Node.new(route[-1].x, route[-1].y - 1))
    when 4
      route = route.push(Node.new(route[-1].x + 1, route[-1].y))
    when 6
      route = route.push(Node.new(route[-1].x - 1, route[-1].y))
    when 8
      route = route.push(Node.new(route[-1].x, route[-1].y + 1))
    else
      Kernel.pbMessage("Error: Something went horrible wrong")
    end
  end

  def printInstruction(instructions)
    if instructions.length == 0
      tts("No route to destination could be found.")
      return
    end
    s = ""
    for instruction in instructions
      #     file.write(instruction.steps.to_s + ", " + instruction.direction.to_s + "\n")
      #s = s + instruction.steps.to_s + (instruction.steps == 1 ? " step " : " steps ") + instruction.direction.to_s + ", "
      s = s + instruction.steps.to_s + " " + instruction.direction.to_s + ", "
    end
    if s.length > 2
      s = s[0..-3]
    end
    s = s + "."
    tts(s)
  end

  def distance(sx, sy, tx, ty)
    return Math.sqrt((sx - tx) * (sx - tx) + (sy - ty) * (sy - ty))
  end

  class Node
    attr_accessor :x, :y, :gCost, :hCost, :parent
    @parent
    @gCost
    @hCost

    def initialize(paraX, paraY)
      @x = paraX
      @y = paraY
      @parent = "none"
    end

    def equals (node)
      return @x == node.x && @y == node.y
    end

    def fCost
      return @gCost + @hCost
    end
  end

  class Instruction
    attr_accessor :steps, :direction
    @steps
    @direction

    def initialize(paraDirection)
      @steps = 1
      @direction = paraDirection
    end
  end

  def distanceNode(node1, node2)
    return distance(node1.x, node1.y, node2.x, node2.y)
  end

  def aStern(start, target, map = $game_map)
    iterations = 0;
    start.gCost = 0

    d = 0
    isTargetPassable = isTargetPassable(target, map)
    targetDirection = getTargetDirection(target, map)
    originalTarget = nil
    if !isTargetPassable && targetDirection != -1
      originalTarget = target
      case targetDirection
      when 2
        target = Node.new(target.x, target.y - 1)
      when 4
        target = Node.new(target.x + 1, target.y)
      when 6
        target = Node.new(target.x - 1, target.y)
      when 8
        target = Node.new(target.x, target.y + 1)
      else
        Kernel.pbMessage("Error: Something went wrong in aStern begin.")
      end
    end

    start.hCost = distanceNode(start, target)
    openSet = []
    closedSet = []
    openSet.push(start)
    while openSet.length > 0 do
      iterations = iterations + 1
      if iterations > 5000
        return []
      end
      s = ""
      for node in openSet
        s = s + node.x.to_s + ", " + node.y.to_s + ";"
      end
      currentNode = openSet[0]
      i = 1
      while i < openSet.length do
        if (openSet[i].fCost < currentNode.fCost || openSet[i].fCost == currentNode.fCost && openSet[i].hCost < currentNode.hCost)
          currentNode = openSet[i]
        end
        i = i + 1
      end

      openSet.delete(currentNode)
      closedSet.push(currentNode)
      #   Kernel.pbMessage("current Node is " + currentNode.x.to_s + ", " + currentNode.y.to_s)
      s = ""
      for node in openSet
        s = s + node.x.to_s + ", " + node.y.to_s + ";"
      end

      if currentNode.equals(target)
        return retracePath(start, currentNode, isTargetPassable, targetDirection, originalTarget)
      end

      neighbours = getNeighbours(currentNode, target, isTargetPassable, targetDirection, map)
      for neighbour in neighbours
        if nodeInSet(neighbour, closedSet)
          next
        end
        neighbourIndex = getNodeIndexInSet(neighbour, openSet)
        newMovementCostToNeighbour = 2
        if currentNode.parent != "none"
          xDifNeighbour = neighbour.x - currentNode.x
          yDifNeighbour = neighbour.y - currentNode.y
          xDifParent = currentNode.x - currentNode.parent.x
          yDifParent = currentNode.y - currentNode.parent.y
          if xDifNeighbour == xDifParent && yDifNeighbour == yDifParent
            newMovementCostToNeighbour = currentNode.gCost + 1
          else
            newMovementCostToNeighbour = currentNode.gCost + 1.5
          end
        else
          newMovementCostToNeighbour = 1.5
        end

        if neighbourIndex > -1 && newMovementCostToNeighbour < openSet[neighbourIndex].gCost
          openSet[neighbourIndex].gCost = newMovementCostToNeighbour
          openSet[neighbourIndex].hCost = distanceNode(openSet[neighbourIndex], target)
          openSet[neighbourIndex].parent = currentNode
        end
        if (neighbourIndex == -1)
          neighbour.gCost = newMovementCostToNeighbour
          neighbour.hCost = distanceNode(neighbour, target)
          neighbour.parent = currentNode
          openSet.push(neighbour)
        end
      end
    end
    return []
  end

  def retracePath(start, target, isTargetPassable, targetDirection, originalTarget)
    path = []
    currentNode = target
    while !currentNode.equals(start) do
      path.push(currentNode)
      currentNode = currentNode.parent
    end
    path = path.reverse

    if isTargetPassable && targetDirection != -1 #Signs without filling an event
      case targetDirection
      when 2
        path.push(Node.new(target.x, target.y + 1))
      when 4
        path.push(Node.new(target.x - 1, target.y))
      when 6
        path.push(Node.new(target.x + 1, target.y))
      when 8
        path.push(Node.new(target.x, target.y - 1))
      else
        Kernel.pbMessage("Error: Something went wrong in aStern()")
      end
    end
    if !isTargetPassable && targetDirection != -1 #immovable objects, which require the operation from a specific direction
      path.push(originalTarget)
    end
    return path
  end

  def getNodeIndexInSet(neighbour, set)
    i = 0
    while i < set.length do
      if set[i].equals(neighbour)
        return i
      end
      i = i + 1
    end
    return -1
  end

  def nodeInSet(neighbour, set)
    for node in set
      if node.equals(neighbour)
        return true
      end
    end
    return false
  end

def getNeighbours(node, target, isTargetPassable, targetDirection, map)
    neighbours = []
    if isTargetPassable || targetDirection != -1
      if is_path_passable?(node.x, node.y, 2)
        neighbours.push(Node.new(node.x, node.y + 1))
      end
      if is_path_passable?(node.x, node.y, 4)
        neighbours.push(Node.new(node.x - 1, node.y))
      end
      if is_path_passable?(node.x, node.y, 6)
        neighbours.push(Node.new(node.x + 1, node.y))
      end
      if is_path_passable?(node.x, node.y, 8)
        neighbours.push(Node.new(node.x, node.y - 1))
      end
    else
      if is_path_passable?(node.x, node.y, 2) || target.equals(Node.new(node.x, node.y + 1))
        neighbours.push(Node.new(node.x, node.y + 1))
      end
      if is_path_passable?(node.x, node.y, 4) || target.equals(Node.new(node.x - 1, node.y))
        neighbours.push(Node.new(node.x - 1, node.y))
      end
      if is_path_passable?(node.x, node.y, 6) || target.equals(Node.new(node.x + 1, node.y))
        neighbours.push(Node.new(node.x + 1, node.y))
      end
      if is_path_passable?(node.x, node.y, 8) || target.equals(Node.new(node.x, node.y - 1))
        neighbours.push(Node.new(node.x, node.y - 1))
      end
    end
    return neighbours
  end
  
  def getTargetDirection(target, map)
    for event in map.events.values
      if event.x != target.x || event.y != target.y
        next
      end
      next if event.list.nil?
      for eventCommand in event.list
        if eventCommand.code.to_s == 111.to_s
          if eventCommand.parameters[0] != nil && eventCommand.parameters[1] != nil && eventCommand.parameters[0].to_s == 6.to_s && eventCommand.parameters[1].to_s == -1.to_s
            return eventCommand.parameters[2]
          end
        end
      end
    end
    return -1
  end

  def isTargetPassable(target, map = $game_map)
    return passableEx?(target.x, target.y - 1, 2, false, map) || passableEx?(target.x + 1, target.y, 4, false, map) || passableEx?(target.x - 1, target.y, 6, false, map) || passableEx?(target.x, target.y + 1, 8, false, map)
  end

  def access_mod_update
    # Remember whether or not moving in local variables
    last_moving = moving?
    # If moving, event running, move route forcing, and message window
    # display are all not occurring
    dir=Input.dir4
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing or
           $PokemonTemp.miniupdate
      # Move player in the direction the directional button is being pressed
      if dir==@lastdir && Graphics.frame_count-@lastdirframe>2
        case dir
          when 2
            move_down
          when 4
            move_left
          when 6
            move_right
          when 8
            move_up
        end
      elsif dir!=@lastdir
        case dir
          when 2
            turn_down
          when 4
            turn_left
          when 6
            turn_right
          when 8
            turn_up
        end
      end
    end
    $PokemonTemp.dependentEvents.updateDependentEvents
    if dir!=@lastdir
      @lastdirframe=Graphics.frame_count
    end
    @lastdir=dir
    # Remember coordinates in local variables
    last_real_x = @real_x
    last_real_y = @real_y
    super
    center_x = (Graphics.width/2 - Game_Map::TILEWIDTH/2) * Game_Map::XSUBPIXEL   # Center screen x-coordinate * 4
    center_y = (Graphics.height/2 - Game_Map::TILEHEIGHT/2) * Game_Map::YSUBPIXEL   # Center screen y-coordinate * 4
    # If character moves down and is positioned lower than the center
    # of the screen
    if @real_y > last_real_y and @real_y - $game_map.display_y > center_y
      # Scroll map down
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # If character moves left and is positioned more left on-screen than
    # center
    if @real_x < last_real_x and @real_x - $game_map.display_x < center_x
      # Scroll map left
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # If character moves right and is positioned more right on-screen than
    # center
    if @real_x > last_real_x and @real_x - $game_map.display_x > center_x
      # Scroll map right
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # If character moves up and is positioned higher than the center
    # of the screen
    if @real_y < last_real_y and @real_y - $game_map.display_y < center_y
      # Scroll map up
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # Count down the time between allowed bump sounds
    @bump_se-=1 if @bump_se && @bump_se>0
    # If not moving
    unless moving?
      if Input.trigger?(Input::F6)
      populate_event_list
      tts('Map list refreshed')
    end

        # Make sure we have events to cycle through
    if !@mapevents.nil? && !@mapevents.empty?
      
      # Cycle to the PREVIOUS event (J)
      if Input.triggerex?(0x4A)
        @selected_event_index -= 1
        if @selected_event_index < 0
          @selected_event_index = @mapevents.size - 1 # Wrap around
        end
        announce_selected_event
      end

      # Cycle to the NEXT event (L)
      if Input.triggerex?(0x4C)
        @selected_event_index += 1
        if @selected_event_index >= @mapevents.size
          @selected_event_index = 0 # Wrap around
        end
        announce_selected_event
      end
      
      # ANNOUNCE the current event (K)
      if Input.triggerex?(0x4B)
        announce_selected_event
      end
      
      # PATHFIND to the current event
      if Input.triggerex?(0x50)
        pathfind_to_selected_event
      end
    end
      # If player was moving last time
      if last_moving
        $PokemonTemp.dependentEvents.pbTurnDependentEvents
        result = pbCheckEventTriggerFromDistance([2])
        # Event determinant is via touch of same position event
        result |= check_event_trigger_here([1,2])
        # If event which started does not exist
        Kernel.pbOnStepTaken(result) # *Added function call
      end
      # If C button was pressed
      if Input.trigger?(Input::C) && !$PokemonTemp.miniupdate
        # Same position and front event determinant
        check_event_trigger_here([0])
        check_event_trigger_there([0,2]) # *Modified to prevent unnecessary triggers
      end
    end
  end
end

class Game_Character
  def passableEx?(x, y, d, strict = false, map = self.map)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return false unless map.valid?(new_x, new_y)
    return true if @through
    if strict
      return false unless map.passableStrict?(x, y, d, self)
      return false unless map.passableStrict?(new_x, new_y, 10 - d, self)
    else
      return false unless map.passable?(x, y, d, self)
      return false unless map.passable?(new_x, new_y, 10 - d, self)
    end
    for event in map.events.values
      if event.x == new_x and event.y == new_y
        unless event.through
          return false if self != $game_player || event.character_name != ""
        end
      end
    end
    if $game_player.x == new_x and $game_player.y == new_y
      unless $game_player.through
        return false if @character_name != ""
      end
    end
    return true
  end
end

class Scene_Map
  # A flag to ensure we only load the names once per game session
  @@pra_names_loaded = false

  alias_method :access_mod_original_main, :main
  def main
    # Load custom event names if they haven't been loaded yet
    if !@@pra_names_loaded
      load_custom_names
      @@pra_names_loaded = true
    end
    
    # Force an initial population of the event list to prevent TTS freeze
    $game_player.populate_event_list if $game_player
    
    # Call the original main method to start the game loop as normal
    access_mod_original_main
  end
end

#===============================================================================
# Data System for Custom Event Names
#===============================================================================
# Define the global hash to store names while the game is running
$custom_event_names = {}
# Define the path for our save file
CUSTOM_NAMES_FILE = "pra-custom-names.txt"

# Method to load the custom names from the file
def load_custom_names
  # Ensure the hash is empty before loading
  $custom_event_names = {}
  
  return unless File.exist?(CUSTOM_NAMES_FILE)

  File.open(CUSTOM_NAMES_FILE, "r") do |file|
    file.each_line do |line|
      # Skip comments and empty lines
      next if line.start_with?("#") || line.strip.empty?
      
      parts = line.strip.split(";")
      # Ensure the line has at least the minimum required columns
      next if parts.length < 5 
      
      map_id, map_name, x, y, event_name, description = parts
      
      # Create a unique key from the map ID and coordinates
      key = "#{map_id};#{x};#{y}"
      
      # Store the data in our global hash
      $custom_event_names[key] = {
        map_name: map_name,
        event_name: event_name,
        description: description || ""
      }
    end
  end
  tts ("Custom event names loaded from #{CUSTOM_NAMES_FILE}.")
end

# Method to save the custom names to the file
def save_custom_names
  # --- Documentation Header ---
  header = <<~TEXT
    # Pokémon Reborn Access - Custom Event Names
    # This file allows you to provide custom, meaningful names for in-game events.
    # The mod will automatically read this file when the game starts.
    #
    # --- FORMAT ---
    # Each line must have 6 fields, separated by a semicolon (;).
    # map_id;map_name;coord_x;coord_y;event_name;description
    #
    # --- HOW TO GET DATA ---
    # Use the in-game scanner to select an event.
    # - Press 'D' to get the Map ID and Map Name.
    # - Press 'Shift+P' to get the X and Y coordinates.
    #
    # --- IMPORTANT ---
    # - Do NOT use semicolons (;) in any of the names or descriptions.
    # - You can also create entries in-game by pressing Shift+K on a selected event.
    #
    # For the full, detailed guide, please visit the project's README on GitHub:
    # [https://github.com/fclorenzo/pkreborn-access]
    #
    # Link to the community-managed Google Doc:
    # [https://docs.google.com/document/d/1OCNpQe4GQEQAycn-1AK4IINBfW09BkNd49YbTn7hiv0/edit?usp=sharing]
  TEXT

  File.open(CUSTOM_NAMES_FILE, "w") do |file|
    # Write the header to the file
    file.puts(header)
    
    # Iterate through the in-memory hash and write each entry to the file
    $custom_event_names.each do |key, value|
      map_id, x, y = key.split(";")
      
      # Format the line according to our spec
      line = [
        map_id,
        value[:map_name],
        x,
        y,
        value[:event_name],
        value[:description]
      ].join(";")
      
      file.puts(line)
    end
  end
  tts ("Custom event names saved to #{CUSTOM_NAMES_FILE}.")
end

#===============================================================================
# ** Bug Fix for addMovedEvent Crash **
# This patches a base game method to prevent a crash with certain events.
#===============================================================================
class PokemonMapMetadata
  # Re-open the class to overwrite the method
  def addMovedEvent(eventID)
    key = [$game_map.map_id, eventID]
    event = $game_map.events[eventID]
    # --- SAFETY CHECK START ---
    # If the event doesn't exist on the current map, do nothing instead of crashing.
    return if event.nil?
    # --- SAFETY CHECK END ---
    @movedEvents[key] = [event.x, event.y, event.direction, event.through, event.opacity]
  end
end