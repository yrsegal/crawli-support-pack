
class PokemonMartScene


  def pbChooseNumber(helptext,item,maximum)
    curnumber=1
    ret=0
    helpwindow=@sprites["helpwindow"]
    itemprice=@adapter.getPrice(item,!@buying)
    itemprice/=2 if !@buying
    pbDisplay(helptext,true)
    using_block(numwindow=Window_AdvancedTextPokemon.new("")){ # Showing number of items
       qty=@adapter.getQuantity(item)
       using_block(inbagwindow=Window_AdvancedTextPokemon.new("")){ # Showing quantity in bag
          pbPrepareWindow(numwindow)
          pbPrepareWindow(inbagwindow)
          numwindow.viewport=@viewport
          numwindow.width=224
          numwindow.height=64
          numwindow.baseColor=Color.new(88,88,80)
          numwindow.shadowColor=Color.new(168,184,184)
          inbagwindow.visible=@buying
          inbagwindow.viewport=@viewport
          inbagwindow.width=190
          inbagwindow.height=64
          inbagwindow.baseColor=Color.new(88,88,80)
          inbagwindow.shadowColor=Color.new(168,184,184)
          inbagwindow.text=_ISPRINTF("In Bag:<r>{1:d}  ",qty)
          tts("In Bag: " + qty.to_s) ### MODDED
          numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
          pbBottomRight(numwindow)
          numwindow.y-=helpwindow.height
          pbBottomLeft(inbagwindow)
          inbagwindow.y-=helpwindow.height
          loop do
            Graphics.update
            Input.update
            numwindow.update
            inbagwindow.update
            self.update
            if Input.repeat?(Input::LEFT)
              pbPlayCursorSE()
              curnumber-=10
              curnumber=1 if curnumber<1
              tts(curnumber.to_s) ### MODDED
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
              tts("$" + (curnumber * itemprice).to_s) ### MODDED
            elsif Input.repeat?(Input::RIGHT)
              pbPlayCursorSE()
              curnumber+=10
              curnumber=maximum if curnumber>maximum
              tts(curnumber.to_s) ### MODDED
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
              tts("$" + (curnumber * itemprice).to_s) ### MODDED
            elsif Input.repeat?(Input::UP)
              pbPlayCursorSE()
              curnumber+=1
              curnumber=1 if curnumber>maximum
              tts(curnumber.to_s) ### MODDED
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
              tts("$" + (curnumber * itemprice).to_s) ### MODDED
            elsif Input.repeat?(Input::DOWN)
              pbPlayCursorSE()
              curnumber-=1
              curnumber=maximum if curnumber<1
              tts(curnumber.to_s) ### MODDED
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
              tts("$" + (curnumber * itemprice).to_s) ### MODDED
            elsif Input.trigger?(Input::C)
              pbPlayDecisionSE()
              ret=curnumber
              break
            elsif Input.trigger?(Input::B)
              pbPlayCancelSE()
              ret=0
              break
            end     
          end
       }
    }
    helpwindow.visible=false
    return ret
  end

  alias :crawlittsparty_old_pbShowMoney :pbShowMoney

  def pbShowMoney
    tts("Money: $" + @adapter.getMoney().to_s)
    crawlittsparty_old_pbShowMoney
  end

  alias :crawlittsparty_old_pbDisplay :pbDisplay

  def pbDisplay(msg, brief = false)
    tts(msg)
    return crawlittsparty_old_pbDisplay(msg, brief)
  end

  alias :crawlittsparty_old_pbDisplayPaused :pbDisplayPaused

  def pbDisplayPaused(msg)
    tts(msg)
    return crawlittsparty_old_pbDisplayPaused(msg)
  end

  alias :crawlittsparty_old_pbConfirm :pbConfirm

  def pbConfirm(msg)
    tts(msg)
    return crawlittsparty_old_pbConfirm(msg)
  end

  def pbChooseBuyItem
    itemwindow=@sprites["itemwindow"]
    @sprites["helpwindow"].visible=false
    pbActivateWindow(@sprites,"itemwindow"){
       pbRefresh
      ### MODDED/
      tts("Money: $" + @adapter.getMoney().to_s)
      if !itemwindow.item.nil?
        tts(@adapter.getDisplayName(itemwindow.item))
        tts("$" + @adapter.getPrice(itemwindow.item).to_s)
        tts(@adapter.getDescription(itemwindow.item))
      else
        tts("CANCEL")
        tts("Quit shopping.")
      end
      ### /MODDED
       loop do
         Graphics.update
         Input.update
         olditem=itemwindow.item
         self.update
         if itemwindow.item!=olditem
           filename=@adapter.getItemIcon(itemwindow.item)
           @sprites["icon"].setBitmap(filename)
           @sprites["icon"].src_rect=@adapter.getItemIconRect(itemwindow.item)   
           @sprites["itemtextwindow"].text=(itemwindow.item.nil?) ? _INTL("Quit shopping.") :
              @adapter.getDescription(itemwindow.item)
          ### MODDED/
          if !itemwindow.item.nil?
            tts(@adapter.getDisplayName(itemwindow.item))
            tts("$" + @adapter.getPrice(itemwindow.item).to_s)
            tts(@adapter.getDescription(itemwindow.item))
          else
            tts("CANCEL")
            tts("Quit shopping.")
          end
          ### /MODDED
         end
         if Input.trigger?(Input::B)
           return nil
         end
         if Input.trigger?(Input::C)
           if itemwindow.index<@stock.length
             pbRefresh
             return @stock[itemwindow.index]
           else
             return nil
           end
         end
       end
    }
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") {
      pbRefresh
      tts("Money: $" + @adapter.getMoney().to_s)
      if !itemwindow.item.nil?
        tts(@adapter.getDisplayName(itemwindow.item))
        tts("$" + @adapter.getPrice(itemwindow.item).to_s)
        tts(@adapter.getDescription(itemwindow.item))
      else
        tts("CANCEL")
        tts("Quit shopping.")
      end
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        if itemwindow.item != olditem
          filename = @adapter.getItemIcon(itemwindow.item)
          @sprites["icon"].setBitmap(filename)
          @sprites["icon"].src_rect = @adapter.getItemIconRect(itemwindow.item)
          @sprites["itemtextwindow"].text = (itemwindow.item.nil?) ? _INTL("Quit shopping.") :
             @adapter.getDescription(itemwindow.item)
          if !itemwindow.item.nil?
            tts(@adapter.getDisplayName(itemwindow.item))
            tts("$" + @adapter.getPrice(itemwindow.item).to_s)
            tts(@adapter.getDescription(itemwindow.item))
          else
            tts("CANCEL")
            tts("Quit shopping.")
          end

        end
        if Input.trigger?(Input::B)
          return nil
        end

        if Input.trigger?(Input::C)
          if itemwindow.index < @stock.length
            pbRefresh
            return @stock[itemwindow.index]
          else
            return nil
          end
        end
      end
    }
  end
end
