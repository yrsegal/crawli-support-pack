class TilePuzzleScene
  def pbMain
    ### MODDED/
    if Kernel.pbConfirmMessage(_INTL("Do you want to skip this tile puzzle?"))
      return true
    end
    ### /MODDED
    loop do
      update
      Graphics.update
      Input.update
      # Check end conditions
      if pbCheckWin
        @sprites["cursor"].visible=false
        if @game==3
          extratile=@sprites["tile#{@boardwidth*@boardheight-1}"]
          extratile.bitmap.clear
          extratile.bitmap.blt(0,0,@tilebitmap.bitmap,
             Rect.new(@tilewidth*(@boardwidth-1),@tileheight*(@boardheight-1),
             @tilewidth,@tileheight))
          extratile.opacity=0
          32.times do
            extratile.opacity+=8
            Graphics.update
            Input.update
          end
        else
          pbWait(5)
        end
        loop do
          Graphics.update
          Input.update
          break if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        end
        return true
      end
      # Input
      @sprites["cursor"].selected=(Input.press?(Input::C) && @game>=3 && @game<=6)
      dir=0
      dir=2 if Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)
      dir=4 if Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
      dir=6 if Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
      dir=8 if Input.trigger?(Input::UP) || Input.repeat?(Input::UP)
      if dir>0
        if @game==3 || (@game!=3 && @sprites["cursor"].selected)
          if pbCanMoveInDir?(@sprites["cursor"].position,dir,true)
            pbSEPlay("Choose")
            pbSwapTiles(dir)
          end
        else
          if pbCanMoveInDir?(@sprites["cursor"].position,dir,false)
            pbSEPlay("Choose")
            @sprites["cursor"].position=pbMoveCursor(@sprites["cursor"].position,dir)
          end
        end
      elsif (@game==1 || @game==2) && Input.trigger?(Input::C)
        pbGrabTile(@sprites["cursor"].position)
      elsif (@game==2 && Input.trigger?(Input::Y)) ||
            (@game==5 && Input.trigger?(Input::Y)) ||
            (@game==7 && Input.trigger?(Input::C))
        pbRotateTile(@sprites["cursor"].position)
      elsif Input.trigger?(Input::B)
        ### MODDED/
        choice = Kernel.pbMessage(_INTL("What would you like to do?"), [_INTL("Quit Puzzle"), _INTL("Skip Puzzle"), _INTL("Cancel")], 3)
        if choice == 0
          return false
        elsif choice == 1
          return true
        end
        ### /MODDED
      end
    end
  end
end
