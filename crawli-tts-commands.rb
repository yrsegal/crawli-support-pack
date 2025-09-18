
class SpriteWindow_Selectable

  def update
    super
    if self.active && @item_max > 0 && @index >= 0 && !@ignore_input
      if Input.repeat?(Input::DOWN)
        if (Input.trigger?(Input::DOWN) && (@item_max % @column_max)==0) || @index < @item_max - @column_max
          oldindex=@index
          @index = (@index + @column_max) % @item_max
          if @index!=oldindex
            item_changed ### MODDED
          end
        end
      end
      if Input.repeat?(Input::UP)
        if (Input.trigger?(Input::UP) && (@item_max % @column_max)==0) || @index >= @column_max
          oldindex=@index
          @index = (@index - @column_max + @item_max) % @item_max
          if @index!=oldindex
            item_changed ### MODDED
          end
        end
      end
      if Input.repeat?(Input::RIGHT)
        if @column_max >= 2 && @index < @item_max - 1
          oldindex=@index
          @index += 1
          if @index!=oldindex
            item_changed ### MODDED
          end
        end
      end
      if Input.repeat?(Input::LEFT)
        if @column_max >= 2 && @index > 0
          oldindex=@index
          @index -= 1
          if @index!=oldindex
            item_changed ### MODDED
          end
        end
      end
      if Input.repeat?(Input::R)
        if self.index < @item_max-1
          oldindex=@index
          @index = [self.index+self.page_item_max, @item_max-1].min
          if @index!=oldindex
            ### MODDED/
            self.top_row += self.page_row_max
            item_changed
            ### /MODDED
          end
        end
      end
      if Input.repeat?(Input::L)
        if self.index > 0
          oldindex=@index
          @index = [self.index-self.page_item_max, 0].max
          if @index!=oldindex
            ### MODDED/
            self.top_row -= self.page_row_max
            item_changed
            ### /MODDED
          end
        end
      end
    end
  end

  def item_changed
    pbPlayCursorSE
    update_cursor_rect
  end
end


class Window_CommandPokemon

  def notts
    @notts = true
  end

  def commands=(value)
    @commands = value
    tts(@commands[0]) if @commands && @commands[0] && !@notts
    @item_max = commands.length
    self.update_cursor_rect
    self.refresh
  end

  def item_changed
    Kernel.tts(@commands[self.index]) if @commands && !@notts
  end
end