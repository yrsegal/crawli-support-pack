# based on https://github.com/mrtenda/voltorbflipdotcom

class VoltorbFlip

  Voltorbfliphelpercrawli_LineTotal = Struct.new('LineTotal', :totalPoints, :totalVoltorbs)
  Voltorbfliphelpercrawli_LineData = Struct.new('LineData', :remainingPoints, :remainingVoltorbs, :unsolvedTiles, :unimportantTiles)

  def voltorbfliphelpercrawli_analysis
    squareData = []

    rows = Array.new(5) { |row| 
      Enumerator.new do |y|
        for col in 0...5
          y << squareData[5 * row + col]
        end
      end
    }

    cols = Array.new(5) { |col| 
      Enumerator.new do |y|
        for row in 0...5
          y << squareData[5 * row + col]
        end
      end
    }

    for row in 0...5
      for col in 0...5
        idx = row * 5 + col
        xpos, ypos, square, flipped = @squares[idx]

        if flipped
          squareData[idx] = [false, false, false, false]
          squareData[idx][square] = true
        else
          squareData[idx] = [true, true, true, true]
        end
      end
    end

    loop do
      rowDatas = Array.new(5) { |i| Voltorbfliphelpercrawli_LineData.new(@rowTotals[i].totalPoints, @rowTotals[i].totalVoltorbs, 0, 0) }
      colDatas = Array.new(5) { |i| Voltorbfliphelpercrawli_LineData.new(@colTotals[i].totalPoints, @colTotals[i].totalVoltorbs, 0, 0) }

      for row in 0...5
        for col in 0...5

          idx = row * 5 + col
          sqdata = squareData[idx]

          rowData = rowDatas[row]
          colData = colDatas[col]
          if sqdata.one? # Solved
            square = sqdata.index(true)
            voltorb = square == 0

            rowData.remainingPoints -= square
            rowData.remainingVoltorbs -= 1 if voltorb

            colData.remainingPoints -= square
            colData.remainingVoltorbs -= 1 if voltorb
          else
            rowData.unsolvedTiles += 1
            rowData.unimportantTiles += 1 if sqdata == [true, true, false, false]
            colData.unsolvedTiles += 1
            colData.unimportantTiles += 1 if sqdata == [true, true, false, false]
          end
        end
      end

      anyUpdate = false

      for rowIdx in 0...5
        row = rows[rowIdx]
        rowData = rowDatas[rowIdx]
        next if rowData.unsolvedTiles == 0 # no unsolved tiles left

        anyUpdate = voltorbfliphelpercrawli_runheuristics(rowData, row)
        break if anyUpdate
      end

      next if anyUpdate

      for colIdx in 0...5
        col = cols[colIdx]
        colData = colDatas[colIdx]
        next if colData.unsolvedTiles == 0 # no unsolved tiles left

        anyUpdate = voltorbfliphelpercrawli_runheuristics(colData, col)
        break if anyUpdate
      end

      @lastrowDatas = rowDatas
      @lastcolDatas = colDatas
      return squareData unless anyUpdate
    end
  end

  def voltorbfliphelpercrawli_runheuristics(lineData, line)
    return (
      voltorbfliphelpercrawli_heuristic0(lineData, line) || 
      voltorbfliphelpercrawli_heuristic1(lineData, line) || 
      voltorbfliphelpercrawli_heuristic2(lineData, line) || 
      voltorbfliphelpercrawli_heuristic3(lineData, line) || 
      voltorbfliphelpercrawli_heuristic4(lineData, line) || 
      voltorbfliphelpercrawli_heuristic5(lineData, line) || 
      voltorbfliphelpercrawli_heuristic6(lineData, line) || 
      voltorbfliphelpercrawli_heuristic7(lineData, line) || 
      voltorbfliphelpercrawli_heuristic8(lineData, line) || 
      voltorbfliphelpercrawli_heuristic9(lineData, line))
  end

  # Heuristic #0 - If RemainingVoltorbs + RemainingPoints == NumUnsolvedTiles, eliminate all possibilities except V and 1 from unsolved tiles
  def voltorbfliphelpercrawli_heuristic0(lineData, line)
    return false if lineData.remainingVoltorbs + lineData.remainingPoints != lineData.unsolvedTiles

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[2] || tile[3]
        tile[2] = false
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #1 - If NumUnsolvedTiles - RemainingVoltorbs == RemainingPoints - 1, remove 3 as a possible option
  def voltorbfliphelpercrawli_heuristic1(lineData, line)
    return false if lineData.unsolvedTiles - lineData.remainingVoltorbs != lineData.remainingPoints - 1

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[3]
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #2 - If RemainingVoltorbs == 0, eliminate any possible voltorbs
  def voltorbfliphelpercrawli_heuristic2(lineData, line)
    return false if lineData.remainingVoltorbs != 0

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[0]
        tile[0] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #3 - If NumUnsolvedTiles - 1 == RemainingVoltorbs, mark all tiles as either voltorbs or tiles with a value of RemainingPoints
  def voltorbfliphelpercrawli_heuristic3(lineData, line)
    return false if lineData.unsolvedTiles - 1 != lineData.remainingVoltorbs

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        for value in 1..3
          next if lineData.remainingPoints == value
          anyUpdate = true if tile[value]
          tile[value] = false
        end
      end
    end
    return anyUpdate
  end

  # Heuristic #4 - If (NumUnsolvedTiles - RemainingVoltorbs) <= ((RemainingPoints + 1)/3), eliminate 1 as a possibility from all tiles
  def voltorbfliphelpercrawli_heuristic4(lineData, line)
    return false if (lineData.unsolvedTiles - lineData.remainingVoltorbs) > ((lineData.remainingPoints + 1) / 3)

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[1]
        tile[1] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #5 - If RemainingVoltorbs == 0 and RemainingPoints = NumUnsolvedTiles, mark all unsolved tiles as definitely 1s
  def voltorbfliphelpercrawli_heuristic5(lineData, line)
    return false if !((lineData.remainingVoltorbs == 0) && (lineData.remainingPoints == lineData.unsolvedTiles))

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true
        tile[0] = false
        tile[1] = true
        tile[2] = false
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #6 - If RemainingVoltorbs == NumUnsolvedTiles, mark all unsolved tiles as definitely voltorbs
  def voltorbfliphelpercrawli_heuristic6(lineData, line)
    return false if lineData.remainingVoltorbs != lineData.unsolvedTiles

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true
        tile[0] = true
        tile[1] = false
        tile[2] = false
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #7 - If NumUnsolvedTiles == 1, fill in the single unsolved tile using RemainingPoints
  def voltorbfliphelpercrawli_heuristic7(lineData, line)
    return false if lineData.unsolvedTiles != 1 || lineData.remainingPoints > 3 # points > 3 is not possible, so to avoid a panic

    for tile in line
      unless tile.one? # Solved
        for value in 0..3
          tile[value] = (value == lineData.remainingPoints)
        end
        return true
      end
    end
    return false
  end

  # Heuristic #8 - If RemainingPoints == NumUnsolvedTiles*3, mark all unknowns as definitely 3s
  def voltorbfliphelpercrawli_heuristic8(lineData, line)
    return false if lineData.remainingPoints != lineData.unsolvedTiles * 3

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true
        tile[0] = false
        tile[1] = false
        tile[2] = false
        tile[3] = true
      end
    end

    return anyUpdate
  end

  ### Wire's custom heuristics

  # Heuristic #9 - If (NumUnsolvedTiles - NumUnimportantTiles) <= ((RemainingPoints + 1)/3), eliminate voltorb as a possibility from all important tiles
  def voltorbfliphelpercrawli_heuristic9(lineData, line)
    return false if (lineData.unsolvedTiles - lineData.unimportantTiles) > ((lineData.remainingPoints - lineData.unimportantTiles + lineData.remainingVoltorbs + 1) / 3)

    anyUpdate = false
    for tile in line
      unless tile.one? || tile == [true, true, false, false] # Solved
        anyUpdate = true if tile[0]
        tile[0] = false
      end
    end
    return anyUpdate
  end












  alias :voltorbfliphelpercrawli_old_pbNewGame :pbNewGame

  def pbNewGame
    tts("New Game of Voltorb Flip! Press [Z] for hints.")

    voltorbfliphelpercrawli_old_pbNewGame

    @rowTotals = Array.new(5) { Voltorbfliphelpercrawli_LineTotal.new(0, 0) }
    @colTotals = Array.new(5) { Voltorbfliphelpercrawli_LineTotal.new(0, 0) }

    for row in 0...5
      for col in 0...5
        idx = row * 5 + col
        xpos, ypos, square, flipped = @squares[idx]
        voltorb = square == 0

        rowTotal = @rowTotals[row]
        colTotal = @colTotals[col]

        rowTotal.totalPoints += square
        rowTotal.totalVoltorbs += 1 if voltorb

        colTotal.totalPoints += square
        colTotal.totalVoltorbs += 1 if voltorb
      end
    end

    voltorbfliphelpercrawli_readouttile(doRow: true, doCol: true)
  end

  def voltorbfliphelpercrawli_readouttile(doRow: false, doCol: false)
    idx = @index[0] * 5 + @index[1]
    if @squares[idx][3]
      tts(_INTL("Tile {1}, {2} - Value {3}", @index[0] + 1, @index[1] + 1, @squares[idx][2]))
    else
      tts(_INTL("Tile {1}, {2}", @index[0] + 1, @index[1] + 1))
    end
    tts(_INTL("Row has {1} points and {2} Voltorbs", @rowTotals[@index[1]].totalPoints, @rowTotals[@index[1]].totalVoltorbs)) if doRow
    tts(_INTL("Column has {1} points and {2} Voltorbs", @colTotals[@index[0]].totalPoints, @colTotals[@index[0]].totalVoltorbs)) if doCol
  end

  def getInput
    if Input.trigger?(Input::UP)
      pbSEPlay("Choose")
      if @index[1]>0
        @index[1]-=1
        @sprites["cursor"].y-=64
      else
        @index[1]=4
        @sprites["cursor"].y=256
      end
      ### MODDED/
      voltorbfliphelpercrawli_readouttile(doRow: true)
      ### /MODDED
    elsif Input.trigger?(Input::DOWN)
      pbSEPlay("Choose")
      if @index[1]<4
        @index[1]+=1
        @sprites["cursor"].y+=64
      else
        @index[1]=0
        @sprites["cursor"].y=0
      end
      ### MODDED/
      voltorbfliphelpercrawli_readouttile(doRow: true)
      ### /MODDED
    elsif Input.trigger?(Input::LEFT)
      pbSEPlay("Choose")
      if @index[0]>0
        @index[0]-=1
        @sprites["cursor"].x-=64
      else
        @index[0]=4
        @sprites["cursor"].x=256
      end
      idx = @index[0] * 5 + @index[1]
      ### MODDED/
      voltorbfliphelpercrawli_readouttile(doCol: true)
      ### /MODDED
    elsif Input.trigger?(Input::RIGHT)
      pbSEPlay("Choose")
      if @index[0]<4
        @index[0]+=1
        @sprites["cursor"].x+=64
      else
        @index[0]=0
        @sprites["cursor"].x=0
      end
      ### MODDED/
      voltorbfliphelpercrawli_readouttile(doCol: true)
      ### /MODDED
    ### MODDED/
    elsif Input.trigger?(Input::A) && !Input.press?(Input::SHIFT)
      if Kernel.pbConfirmMessage(_INTL("Do you want a hint?"))
        analysis = voltorbfliphelpercrawli_analysis

        knownGood = []
        knownBad = []
        knownIrrelevant = []
        knownOne = []

        analysis.each_with_index { |it, idx|
          next if @squares[idx][3]
          solved = it.one?

          if solved && it[0]
            knownBad.push(idx)
          elsif solved && it[1]
            knownOne.push(idx)
          elsif !it[0]
            knownGood.push(idx)
          elsif it == [true, true, false, false]
            knownIrrelevant.push(idx)
          end
        }

        idx = nil
        comment = ""

        if !knownGood.empty?
          idx = knownGood.sample
          comment = "guaranteed to be safe"
        elsif !knownOne.empty?
          idx = knownOne.sample
          comment = "guaranteed to be a 1"
        elsif !knownBad.empty?
          idx = knownBad.sample
          comment = "guaranteed to be a Voltorb"
        elsif !knownIrrelevant.empty?
          idx = knownIrrelevant.sample
          comment = "either a Voltorb or a 1"
        end

        if idx
          x = idx % 5
          y = idx / 5
          Kernel.pbMessage(_INTL("Tile {1}, {2} is {3}.", x + 1, y + 1, comment))

          readRow = @index[0] != x
          readCol = @index[1] != y
          if readRow || readCol
            pbSEPlay("Choose")

            @index[0] = x
            @index[1] = y
            @sprites["cursor"].x = 64 * x
            @sprites["cursor"].y = 64 * y

            voltorbfliphelpercrawli_readouttile(doRow: readRow, doCol: readCol)
          end
        end
      end
    ### /MODDED
    elsif Input.trigger?(Input::C)
      if @cursor[0][3]==64 # If in mark mode
        for i in 0...@squares.length
          if @index[0]*64+128==@squares[i][0] && @index[1]*64==@squares[i][1] && @squares[i][3]==false
            pbSEPlay("Voltorb Flip Mark")
          end
        end
        for i in 0...@marks.length+1
          if @marks[i]==nil
            @marks[i]=[@directory+"tiles",@index[0]*64+128,@index[1]*64,256,0,64,64]
          elsif @marks[i][1]==@index[0]*64+128 && @marks[i][2]==@index[1]*64
            @marks.delete_at(i)
            @marks.compact!
            @sprites["mark"].bitmap.clear
            break
          end
        end
        pbDrawImagePositions(@sprites["mark"].bitmap,@marks)
        pbWait(2)
      else
        # Display the tile for the selected spot
        icons=[]
        for i in 0...@squares.length
          if @index[0]*64+128==@squares[i][0] && @index[1]*64==@squares[i][1] && @squares[i][3]==false
            pbAnimateTile(@index[0]*64+128,@index[1]*64,@squares[i][2])
            @squares[i][3]=true
            # If Voltorb (0), display all tiles on the board
            if @squares[i][2]==0
              pbSEPlay("Voltorb Flip Explosion")
              # Play explosion animation
              # Part1
              animation=[]
              for j in 0...3
                animation[0]=icons[0]=[@directory+"tiles",@index[0]*64+128,@index[1]*64,704+(64*j),0,64,64]
                pbDrawImagePositions(@sprites["animation"].bitmap,animation)
                pbWait(3)
                @sprites["animation"].bitmap.clear
              end
              # Part2
              animation=[]
              for j in 0...6
                animation[0]=[@directory+"explosion",@index[0]*64-32+128,@index[1]*64-32,j*128,0,128,128]
                pbDrawImagePositions(@sprites["animation"].bitmap,animation)
                pbWait(3)
                @sprites["animation"].bitmap.clear
              end
              # Unskippable text block, parameter 2 = wait time (corresponds to ME length)
              Kernel.pbMessage(_INTL("\\me[Voltorb Flip Game Over]Oh no! You get 0 Coins!\\wtnp[50]"))
              pbShowAndDispose
              @sprites["mark"].bitmap.clear
              if @level>1
                # Determine how many levels to reduce by
                newLevel=0
                for j in 0...@squares.length
                  if @squares[j][3]==true && @squares[j][2]>1
                    newLevel+=1
                  end
                end
                if newLevel>@level
                  newLevel=@level
                end
                if @level>newLevel
                  @level=newLevel
                  @level=1 if @level<1
                  Kernel.pbMessage(_INTL("\\se[Voltorb Flip Level Dropped]Dropped to Game Lv. {1}!",@level.to_s))
                end
              end
              # Update level text
              @sprites["level"].bitmap.clear
              pbDrawShadowText(@sprites["level"].bitmap,8,150,118,28,"Level "+@level.to_s,Color.new(60,60,60),Color.new(150,190,170),1)
              @points=0
              pbUpdateCoins
              # Revert numbers to 0s
              @sprites["numbers"].bitmap.clear
              for i in 0...5
                pbUpdateRowNumbers(0,0,i)
                pbUpdateColumnNumbers(0,0,i)
              end
              pbDisposeSpriteHash(@sprites)
              @firstRound=false
              pbNewGame
            else
              # Play tile animation
              animation=[]
              for j in 0...4
                animation[0]=[@directory+"flipAnimation",@index[0]*64-14+128,@index[1]*64-16,j*92,0,92,96]
                pbDrawImagePositions(@sprites["animation"].bitmap,animation)
                pbWait(3)
                @sprites["animation"].bitmap.clear
              end
              if @points==0
                @points+=@squares[i][2]
                pbSEPlay("Voltorb Flip Point")
              elsif @squares[i][2]>1
                @points*=@squares[i][2]
                pbSEPlay("Voltorb Flip Point")
              end
              ### MODDED/
              tts("Flipped a #{@squares[i][2]} point tile")
              ### /MODDED
              break
            end
          end
        end
      end
      count=0
      for i in 0...@squares.length
        if @squares[i][3]==false && @squares[i][2]>1
          count+=1
        end
      end
      pbUpdateCoins
      # Game cleared
      if count==0
        @sprites["curtain"].opacity=100
        Kernel.pbMessage(_INTL("\\me[Voltorb Flip Win]Board clear!\\wtnp[40]"))
#        Kernel.pbMessage(_INTL("You've found all of the hidden x2 and x3 cards."))
#        Kernel.pbMessage(_INTL("This means you've found all the Coins in this game, so the game is now over."))
        Kernel.pbMessage(_INTL("{1} received {2} Coins!",$Trainer.name,pbCommaNumber(@points)))
        # Update level text
        @sprites["level"].bitmap.clear
        pbDrawShadowText(@sprites["level"].bitmap,8,150,118,28,_INTL("Level {1}",@level.to_s),Color.new(60,60,60),Color.new(150,190,170),1)
        $PokemonGlobal.coins+=@points
        @points=0
        pbUpdateCoins
        @sprites["curtain"].opacity=0
        pbShowAndDispose
        # Revert numbers to 0s
        @sprites["numbers"].bitmap.clear
        for i in 0...5
          pbUpdateRowNumbers(0,0,i)
          pbUpdateColumnNumbers(0,0,i)
        end
        @sprites["curtain"].opacity=100
        if @level<8
          @level+=1
          Kernel.pbMessage(_INTL("Advanced to Game Lv. {1}!",@level.to_s))
#          if @firstRound
#            Kernel.pbMessage(_INTL("Congratulations!"))
#            Kernel.pbMessage(_INTL("You can receive even more Coins in the next game!"))
            @firstRound=false
#          end
        end
        pbDisposeSpriteHash(@sprites)
        pbNewGame
      end
    ### MODDED/ Disable mark mode, as for technical reasons it's a pain in this mode + ctrl is the stop speaking key
    # elsif Input.trigger?(Input::CTRL)
    #   pbSEPlay("Choose")
    #   @sprites["cursor"].bitmap.clear
    #   if @cursor[0][3]==0 # If in normal mode
    #     @cursor[0]=[@directory+"cursor",128,0,64,0,64,64]
    #     @sprites["memo"].visible=true
    #   else # Mark mode
    #     @cursor[0]=[@directory+"cursor",128,0,0,0,64,64]
    #     @sprites["memo"].visible=false
    #   end
    ### /MODDED
    elsif Input.trigger?(Input::B)
      @sprites["curtain"].opacity=100
      if @points==0
        if Kernel.pbConfirmMessage("You haven't found any Coins! Are you sure you want to quit?")
          @sprites["curtain"].opacity=0
         pbShowAndDispose
          @quit=true
        end
      elsif Kernel.pbConfirmMessage(_INTL("If you quit now, you will receive {1} Coin(s). Will you quit?",pbCommaNumber(@points)))
        Kernel.pbMessage(_INTL("{1} received {2} Coin(s)!",$Trainer.name,pbCommaNumber(@points)))
        $PokemonGlobal.coins+=@points
        @points=0
        pbUpdateCoins
        @sprites["curtain"].opacity=0
        pbShowAndDispose
        @quit=true
      end
      @sprites["curtain"].opacity=0
    end
    # Draw cursor
    pbDrawImagePositions(@sprites["cursor"].bitmap,@cursor)
  end

  alias :voltorbfliphelpercrawli_old_pbCreateSprites :pbCreateSprites

  def pbCreateSprites
    voltorbfliphelpercrawli_old_pbCreateSprites
    @sprites["bg"].bitmap.fill_rect(10,196,108,124,rgbToColor("29a56b"))
  end

  alias :voltorbfliphelpercrawli_old_pbUpdateCoins :pbUpdateCoins

  def pbUpdateCoins
    tts("Coins: #{$PokemonGlobal.coins}") if @lastcoins != $PokemonGlobal.coins
    @lastcoins = $PokemonGlobal.coins
    tts("Points: #{@points}") if @points != 0 && @lastpoints != @points
    @lastpoints = @points
    voltorbfliphelpercrawli_old_pbUpdateCoins
  end
end
