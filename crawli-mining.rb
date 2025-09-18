class MiningGameScene
  alias :crawlimining_old_pbMain :pbMain

  def pbMain
    if BlindstepActive
      Kernel.pbMessage(_INTL("Mining the rock..."))
      for item in @items
        item_info = ITEMS[item[0]]
        item_name = item_info[0]
        item_x = item[1]
        item_y = item[2]
        item_width = item_info[4]
        item_height = item_info[5]
        item_pattern = item_info[6]
        for i in 0...item_width
          for j in 0...item_height
            x_tile = item_x + i
            y_tile = item_y + j
            tile_index = y_tile * BOARDWIDTH + x_tile
            @sprites["tile#{tile_index}"].layer = 0 if item_pattern[j * item_width + i] == 1
          end
        end
        cursor_x = (item_x + item_width / 2).floor
        cursor_y = (item_y + item_height / 2).floor
        @sprites["cursor"].position = cursor_y * BOARDWIDTH + cursor_x
        pbHit
      end
    end

    crawlimining_old_pbMain
  end
end
