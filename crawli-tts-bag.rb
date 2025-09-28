class PokemonBag_Scene

  def pbChooseItem
    pbRefresh
    pbTMSprites
    @sprites["helpwindow"].visible=false
    itemwindow=@sprites["itemwindow"]
    itemwindow.refresh
    sorting=false
    sortindex=-1
    pbDetermineTMmenu(itemwindow)
    pbActivateWindow(@sprites,"itemwindow"){
      ### MODDED/
      ttsItem(itemwindow.item)
      lastread = itemwindow.item
      ### /MODDED
       loop do
         Graphics.update
         Input.update
         olditem=itemwindow.item
         oldindex=itemwindow.index
         self.update
         if itemwindow.item!=olditem
           # Update slider position
           ycoord=60
           if itemwindow.itemCount>1
             ycoord+=116.0 * itemwindow.index/(itemwindow.itemCount-1)
           end
           @sprites["slider"].y=ycoord
           # Update item icon and description
           filename=pbItemIconFile(itemwindow.item)
           @sprites["icon"].setBitmap(filename)
           @sprites["itemtextwindow"].text=(itemwindow.item.nil?) ? _INTL("Close bag.") : $cache.items[itemwindow.item].desc
           ### MODDED/
           if itemwindow.item != lastread
            ttsItem(itemwindow.item)
            lastread = itemwindow.item
           end
           ### /MODDED
           pbDetermineTMmenu(itemwindow)
         end
         if itemwindow.index!=oldindex
           # Update selected item for current pocket
           @bag.setChoice(itemwindow.pocket,itemwindow.index)
         end
         # Change pockets if Left/Right pressed
         numpockets=PokemonBag.numPockets
         if Input.trigger?(Input::LEFT)
           if !sorting
             itemwindow.pocket=(itemwindow.pocket==1) ? numpockets : itemwindow.pocket-1
             @bag.lastpocket=itemwindow.pocket
             pbRefresh
             pbDetermineTMmenu(itemwindow)
             ### MODDED/
             tts(PokemonBag.pocketNames()[itemwindow.pocket] + " Pocket")
             ttsItem(itemwindow.item)
             lastread = itemwindow.item
             ### /MODDED
           end
         elsif Input.trigger?(Input::RIGHT)
           if !sorting
             itemwindow.pocket=(itemwindow.pocket==numpockets) ? 1 : itemwindow.pocket+1
             @bag.lastpocket=itemwindow.pocket
             pbRefresh
             pbDetermineTMmenu(itemwindow)
             ### MODDED/
             tts(PokemonBag.pocketNames()[itemwindow.pocket] + " Pocket")
             ttsItem(itemwindow.item)
             lastread = itemwindow.item
             ### /MODDED
           end
         end
         if Input.trigger?(Input::X)
           if pbHandleSortByType(itemwindow.pocket) # Returns true if the default sorting should be used
             pocket  = @bag.pockets[itemwindow.pocket]
             counter = 1
             while counter < pocket.length
               index     = counter
               while index > 0
                 indexPrev = index - 1
                 if itemwindow.pocket==TMPOCKET
                   firstName  = (((getItemName(pocket[indexPrev])).sub("TM","00")).sub("X","100")).to_i
                   secondName = (((getItemName(pocket[index])).sub("TM","00")).sub("X","100")).to_i
                 else
                   firstName  = getItemName(pocket[indexPrev])
                   secondName = getItemName(pocket[index])
                 end
                 if firstName > secondName
                   aux               = pocket[index]
                   pocket[index]     = pocket[indexPrev]
                   pocket[indexPrev] = aux
                 end
                 index -= 1
               end
               counter += 1
             end
           end
           pbRefresh
         end
  # Select item for switching if A is pressed
         if Input.trigger?(Input::Y)
           thispocket=@bag.pockets[itemwindow.pocket]
           if itemwindow.index<thispocket.length && thispocket.length>1 &&
              !POCKETAUTOSORT[itemwindow.pocket]
             sortindex=itemwindow.index
             sorting=true
             @sprites["itemwindow"].sortIndex=sortindex
           else
             next
           end
         end
         # Cancel switching or cancel the item screen
         if Input.trigger?(Input::B)
           if sorting
             sorting=false
             @sprites["itemwindow"].sortIndex=-1
           else
             return nil
           end
         end
         # Confirm selection or item switch
         if Input.trigger?(Input::C)
           thispocket=@bag.pockets[itemwindow.pocket]
           if itemwindow.index<thispocket.length
             if sorting
               sorting=false
               tmp=thispocket[itemwindow.index]
               thispocket[itemwindow.index]=thispocket[sortindex]
               thispocket[sortindex]=tmp
               @sprites["itemwindow"].sortIndex=-1
               pbRefresh
               next
             else
               pbRefresh
               tts($cache.items[itemwindow.item].desc) if $cache.items[itemwindow.item] ### MODDED
               return thispocket[itemwindow.index]
             end
           else
             return nil
           end
         end
       end
    }
  end
  
  def ttsItem(item)
    if pbIsTM?(item)
      tts(getItemName(item) + " " + pbGetMachineMoveName(item))
    elsif item
      if @bag.contents[item] > 1 && !pbIsImportantItem?(item)
        tts(@bag.contents[item].to_s + " " + getItemName(item) + "s")
      else
        tts(getItemName(item))
      end
    else
      tts("Close bag")
    end
  end
end
