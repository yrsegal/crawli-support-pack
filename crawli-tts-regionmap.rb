class PokemonRegionMapScene

  def pbMapScene(mode=0)
    xOffset=0
    yOffset=0
    newX=0
    newY=0
    moveMap=false
    ox=0
    oy=0
    mapfocus = false
    mapfocus = true if @showcursor
    lastreadlocation = nil ### MODDED
    loop do
      Graphics.update
      Input.update
      if mode == 2
        @numpoints.times {|i|
          @sprites["point#{i}"].opacity=[64,96,128,160,128,96][(Graphics.frame_count/4)%6]
        }
      end
      pbUpdate
      ### MODDED/
      location = getMapName
      mapdetails = getPOI
      location += ", " + mapdetails if mapdetails && !mapdetails.empty?
      location += " in " + getRegionName
      if mode != 2 && location != lastreadlocation && location != ""
        lastreadlocation = location
        tts(location)
      end
      ### /MODDED
      if xOffset!=0 || yOffset!=0
        xOffset+=xOffset>0 ? -4 : (xOffset<0 ? 4 : 0)
        yOffset+=yOffset>0 ? -4 : (yOffset<0 ? 4 : 0)
        @sprites["cursor"].x=newX-xOffset
        @sprites["cursor"].y=newY-yOffset
        if @mapY > SCREENBOTTOM || @mapY < TOP
          @mapY -= oy
          @viewport.oy += (oy * SQUAREWIDTH)
        end
        if @mapX > SCREENRIGHT || @mapX < LEFT
          @mapX -= ox
          @viewport.ox += (ox * SQUAREWIDTH)
        end
        @sprites["mapbottom"].maplocation=getMapName
        @sprites["mapbottom"].mapdetails=getPOI if mode!=2
        @sprites["mapbottom"].mapname=getRegionName if mode!=2
        next
      end
      ox=0
      oy=0
      if mapfocus
        case Input.dir8
          when 1 # lower left
            oy=1 if @selection[1]<@BOTTOM
            ox=-1 if @selection[0]>LEFT
          when 2 # down
            oy=1 if @selection[1]<@BOTTOM
          when 3 # lower right
            oy=1 if @selection[1]<@BOTTOM
            ox=1 if @selection[0]<@RIGHT
          when 4 # left
            ox=-1 if @selection[0]>LEFT
          when 6 # right
            ox=1 if @selection[0]<@RIGHT
          when 7 # upper left
            oy=-1 if @selection[1]>TOP
            ox=-1 if @selection[0]>LEFT
          when 8 # up
            oy=-1 if @selection[1]>TOP
          when 9 # upper right
            oy=-1 if @selection[1]>TOP
            ox=1 if @selection[0]<@RIGHT
        end
      end

      if ox!=0 || oy!=0
        @mapX += ox
        @mapY += oy
        @selection[0] += ox
        @selection[1] += oy
        xOffset=ox*SQUAREWIDTH
        yOffset=oy*SQUAREHEIGHT
        newX=@sprites["cursor"].x+xOffset
        newY=@sprites["cursor"].y+yOffset
      end

      if mode == 2
        if !mapfocus
          if Input.trigger?(Input::LEFT)
            return :LEFT
          elsif Input.trigger?(Input::RIGHT)
            return :RIGHT
          elsif Input.trigger?(Input::UP)
            return :UP
          elsif Input.trigger?(Input::DOWN)
            return :DOWN
          elsif Input.trigger?(Input::B)
            return :BACK
            pbPlayCancelSE()
            pbFadeOutAndHide(@sprites)
          end
        end
        if Input.trigger?(Input::B)
          if @basemap && !mapfocus
            return @basemap
          end
          if !mapfocus 
            break
          end
          mapfocus = false
          @sprites["cursor"].visible = false
          @sprites["mapbottom"].maplocation=""
        elsif Input.trigger?(Input::C)
          submap = getSubMap(@selection) #checking for submaps
          if submap
            return [submap[:mapid],submap[:basemap]]
          end
          mapfocus = true
          @sprites["cursor"].visible = true
          @sprites["mapbottom"].maplocation=getMapName
        elsif Input.triggerex?(:B) && $INTERNAL
          puts "Pos: [#{@mapX}, #{@mapY}]"
          puts "SelPos: #{@selection.inspect}"
          puts "CurPos: [#{@sprites["cursor"].x}, #{@sprites["cursor"].y}]"
        elsif Input.trigger?(Input::PAGEUP) || Input.trigger?(Input::PAGEDOWN)
          if @region.length > 1
            return 4
          else
            return 0
          end
        end
      else
        if Input.trigger?(Input::B)
          if @basemap
            return @basemap
          else
            if @editor && @changed
              if Kernel.pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
                pbSaveMapData
              end
              if Kernel.pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
                break
              end
            else
              break
            end
          end
        elsif Input.trigger?(Input::C) 
          submap = getSubMap(@selection) #checking for submaps
          if submap
            return [submap[:mapid],submap[:basemap]]
          end
          if mode == 1 # Choosing an area to fly to
            healspot=getFlySpot(@selection)
            if healspot
              if $PokemonGlobal.visitedMaps[healspot[0]] ||
                ($DEBUG && Input.press?(Input::CTRL))
                return healspot
              end
            end
          end
        elsif Input.triggerex?(:B) && $INTERNAL
          puts "Pos: [#{@mapX}, #{@mapY}]"
          puts "SelPos: #{@selection.inspect}"
          puts "CurPos: [#{@sprites["cursor"].x}, #{@sprites["cursor"].y}]"
        elsif Input.trigger?(Input::C) && @editor # Intentionally placed after other C button check
          #pbChangeMapLocation(@mapX,@mapY)
        elsif Input.trigger?(Input::PAGEUP) || Input.trigger?(Input::PAGEDOWN)
          if $game_variables[:GDCStory] > 1
            if @region.length > 1
              return 4
            else
              return 0
            end
          end
        end
      end
    end
    return nil
  end
end