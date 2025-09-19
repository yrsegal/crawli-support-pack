class PokemonPokedexScene
  alias :crawlittspokedex_old_pbStartScene :pbStartScene

  def pbStartScene
    crawlittspokedex_old_pbStartScene

    tts("Pokédex")
    tts("Seen: #{$Trainer.pokedex.getSeenCount()}")
    tts("Owned: #{$Trainer.pokedex.getOwnedCount()}")
  end

  def pbDexSearchCommands(commands,selitem,helptexts=nil)
    ret=-1
    auxlist=@sprites["auxlist"]
    messagebox=@sprites["messagebox"]
    auxlist.commands=commands
    auxlist.index=selitem
    messagebox.text=helptexts ? helptexts[auxlist.index] : ""
    ### MODDED/
    tts(auxlist.commands[auxlist.index])
    tts(messagebox.text) if helptexts
    ### /MODDED
    pbActivateWindow(@sprites,"auxlist"){
       loop do
         Graphics.update
         Input.update
         oldindex=auxlist.index
         pbUpdate
        ### MODDED/
        if auxlist.index != oldindex
          tts(auxlist.commands[auxlist.index])
        end
        ### /MODDED
         if auxlist.index!=oldindex && helptexts
           messagebox.text=helptexts[auxlist.index]
          tts(messagebox.text) ### MODDED
         end
         if Input.trigger?(Input::B)
           ret=selitem
           pbPlayCancelSE()
           break
         end
         if Input.trigger?(Input::C)
           ret=auxlist.index
           pbPlayDecisionSE()
           break
         end
       end
       @sprites["auxlist"].commands=[]
    }
    Input.update
    return ret
  end

  def pbRefreshDexSearch(params)
    searchlist=@sprites["searchlist"]
    messagebox=@sprites["messagebox"]
    searchlist.commands=[
       _INTL("Search"),[
          _ISPRINTF("Name: {1:s}",@nameCommands[params[0]]),
          _ISPRINTF("Color: {1:s}",@colorCommands[params[1]]),
          _ISPRINTF("Type 1: {1:s}",@typeCommands[params[2]]),
          _ISPRINTF("Type 2: {1:s}",@typeCommands[params[3]]),
          _ISPRINTF("Order: {1:s}",@orderCommands[params[4]]),
          _INTL("Start Search")
       ],
       _INTL("Sort"),[
          _ISPRINTF("Order: {1:s}",@orderCommands[params[5]]),
          _INTL("Start Sort")
       ]
    ]
    helptexts=[
       _INTL("Search for Pokémon based on selected parameters."),[
          _INTL("List by the first letter in the name.\r\nSpotted Pokémon only."),
          _INTL("List by body color.\r\nSpotted Pokémon only."),
          _INTL("List by type.\r\nOwned Pokémon only."),
          _INTL("List by type.\r\nOwned Pokémon only."),
          _INTL("Select the Pokédex listing mode."),
          _INTL("Execute search."),
       ],
       _INTL("Switch Pokédex listings."),[
          _INTL("Select the Pokédex listing mode."),
          _INTL("Execute sort."),
       ]
    ]
    messagebox.text=searchlist.getText(helptexts,searchlist.index)
    ### MODDED/
    if searchlist.index <= 6
      tts("Search Parameter:") if searchlist.index != 6
      tts(searchlist.commands[1][searchlist.index - 1])
      tts(helptexts[1][searchlist.index - 1]) if searchlist.index != 6
    else
      tts("Sort Parameter:") if searchlist.index != 9
      tts(searchlist.commands[3][searchlist.index - 8])
      tts(helptexts[3][searchlist.index - 8]) if searchlist.index != 9
    end
    ### /MODDED
  end

  def pbChangeToDexEntry(species)
    if species.is_a?(Integer)
      species = $cache.pkmn.keys[species - 1]
    end
    randomgame = $game_switches[:Randomized_Challenge]==true
    $game_switches[:Randomized_Challenge]=false
    formPoke=PokeBattle_Pokemon.new(species,1,$Trainer)
    $game_switches[:Randomized_Challenge]= randomgame
    formPoke.setGender($Trainer.pokedex.dexList[species][:lastSeen][:gender])
    formPoke.shinyflag = $Trainer.pokedex.dexList[species][:lastSeen][:shiny]
    formPoke.form = $cache.pkmn[species].forms.values.index($Trainer.pokedex.dexList[species][:lastSeen][:form])
    formPoke.form = 0 if formPoke.form.nil?
    @sprites["dexentry"].visible=true
    if !Reborn
      if @sprites["dexbar"] && $game_switches[AdvancedPokedexScene::SWITCH]
        @sprites["dexbar"].visible=true 
      end 
    end
    @sprites["overlay"].visible=true
    @sprites["overlay"].bitmap.clear
    basecolor=Color.new(88,88,80)
    shadowcolor=Color.new(168,184,184)
    speciesInt = $cache.pkmn[species].dexnum
    #indexNumber=pbGetRegionalNumber(pbGetPokedexRegion(),$cache.pkmn[species].dexnum)
    #indexNumber=speciesInt if indexNumber==0
    #indexNumber-=1 if DEXINDEXOFFSETS.include?(pbGetPokedexRegion)
    textpos=[
       [_ISPRINTF("{1:03d}{2:s} {3:s}",speciesInt," ",getMonName(species)),
          244,40,0,Color.new(248,248,248),Color.new(0,0,0)],
       [sprintf(_INTL("HT")),318,158,0,basecolor,shadowcolor],
       [sprintf(_INTL("WT")),318,190,0,basecolor,shadowcolor]
    ]
    if $Trainer.pokedex.dexList[species][:owned?]
      type1=$cache.pkmn[species].Type1
      type2=$cache.pkmn[species].Type2
      if $random_dex != nil
        type1=$random_dex[species].Type1
        type2=$random_dex[species].Type2
      end
      height=$cache.pkmn[species].Height
      weight=$cache.pkmn[species].Weight
      kind=$cache.pkmn[species].kind
      dexentry=$cache.pkmn[species].dexentry
      inches=(height/0.254).round
      pounds=(weight/0.45359).round
      if formPoke.form != 0
        formnames = $cache.pkmn[species].forms
        if formnames != nil
          thisform = formnames[formPoke.form]
          if thisform && $cache.pkmn[species].formData[thisform]
            type1 = $cache.pkmn[species].formData[thisform][:Type1] if $cache.pkmn[species].formData[thisform][:Type1]
            type2 = $cache.pkmn[species].formData[thisform][:Type2] if $cache.pkmn[species].formData[thisform][:Type2]
            type2 = nil if !($cache.pkmn[species].formData[thisform][:Type2]) && $cache.pkmn[species].formData[thisform][:Type1]
            height = $cache.pkmn[species].formData[thisform][:Height] if $cache.pkmn[species].formData[thisform][:Height]
            weight = $cache.pkmn[species].formData[thisform][:Weight] if $cache.pkmn[species].formData[thisform][:Weight]
            dexentry = $cache.pkmn[species].formData[thisform][:dexentry] if $cache.pkmn[species].formData[thisform][:dexentry]
          end
        end
      end
      textpos.push([_ISPRINTF("{1:s} Pokémon",kind),244,74,0,basecolor,shadowcolor])
      if pbGetCountry()==0xF4 # If the user is in the United States
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12),456,158,1,basecolor,shadowcolor])
        textpos.push([_ISPRINTF("{1:4.1f} lbs.",pounds/10.0),490,190,1,basecolor,shadowcolor])
      else
        textpos.push([_ISPRINTF("{1:.1f} m",height/10.0),466,158,1,basecolor,shadowcolor])
        textpos.push([_ISPRINTF("{1:.1f} kg",weight/10.0),478,190,1,basecolor,shadowcolor])
      end
      drawTextEx(@sprites["overlay"].bitmap,
         42,240,Graphics.width-(42*2),4,dexentry,basecolor,shadowcolor)

      footprintfile=pbPokemonFootprintFile($cache.pkmn[species].dexnum)
      if footprintfile
        footprint=RPG::Cache.load_bitmap(footprintfile)
        @sprites["overlay"].bitmap.blt(226,136,footprint,footprint.rect)
        footprint.dispose
      end

      pbDrawImagePositions(@sprites["overlay"].bitmap,[["Graphics/Pictures/Pokedex/pokedexOwned",212,42,0,0,-1,-1]])
      #typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/pokedexTypes"))
      #type1rect=Rect.new(0,type1*32,96,32)
      #type2rect=Rect.new(0,type2*32,96,32)
      type1bitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedex#{type1.to_s}")
      @sprites["overlay"].bitmap.blt(296,118,type1bitmap.bitmap,Rect.new(0,0,96,32))
      type1bitmap.dispose

      if type2 != nil
        type2bitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedex#{type2.to_s}") 
        @sprites["overlay"].bitmap.blt(396,118,type2bitmap.bitmap,Rect.new(0,0,96,32)) 
        type2bitmap.dispose
      end
    else
      textpos.push([_INTL("????? Pokémon"),244,74,0,basecolor,shadowcolor])
      if pbGetCountry()==0xF4 # If the user is in the United States
        textpos.push([_INTL("???'??\""),456,158,1,basecolor,shadowcolor])
        textpos.push([_INTL("????.? lbs."),490,190,1,basecolor,shadowcolor])
      else
        textpos.push([_INTL("????.? m"),466,158,1,basecolor,shadowcolor])
        textpos.push([_INTL("????.? kg"),478,190,1,basecolor,shadowcolor])
      end
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    #pkmnbitmap=AnimatedBitmap.new(pbPokemonBitmapFile(species,false))
    lastGender = $Trainer.pokedex.dexList[species][:lastSeen][:gender]
    lastForm = $Trainer.pokedex.dexList[species][:lastSeen][:form]
    lastShiny = $Trainer.pokedex.dexList[species][:lastSeen][:shiny]
    pkmnbitmap=pbPokemonBitmap(species,lastShiny,false,lastGender,lastForm)
    if formPoke.species==:EXEGGUTOR && formPoke.form==1
      croppedBMP = Bitmap.new(192,192)
      croppedBMP.blt(0,0,pkmnbitmap,croppedBMP.rect)
      pkmnbitmap = croppedBMP
      @sprites["overlay"].bitmap.blt( 40-(pkmnbitmap.width-128)/2, (70-(pkmnbitmap.height-128)/2)+8, pkmnbitmap,pkmnbitmap.rect)
    else
      @sprites["overlay"].bitmap.blt( 40-(pkmnbitmap.width-128)/2, 70-(pkmnbitmap.height-128)/2, pkmnbitmap,pkmnbitmap.rect)
    end
    pkmnbitmap.dispose
    pbPlayCry(formPoke)
    ### MODDED/
    tts(speciesInt.to_s)
    tts(getMonName(species))
    if $Trainer.pokedex.dexList[species][:owned?]
      tts(kind + " Pokémon")
      if type2 != nil
        tts("Types: " + $cache.types[type1].name + " and " + $cache.types[type2].name)
      else
        tts("Type: " + $cache.types[type1].name)
      end
      if pbGetCountry() == 0xF4 # If the user is in the United States
        tts("Height: #{inches / 12} feet #{inches % 12} inches")
        tts("Weight: #{pounds / 10.0} pounds")
      else
        tts("Height: #{height / 10.0} meters")
        tts("Weight: #{weight / 10.0} kilograms")
      end
      tts(dexentry)
    else
      tts("Unknown types")
      tts("Unknown size")
    end
    ### /MODDED
  end
  

  def pbDexSearch
    oldsprites=pbFadeOutAndHide(@sprites)
    params=[]
    params[0]=0
    params[1]=0
    params[2]=0
    params[3]=0
    params[4]=0
    params[5]=$PokemonGlobal.pokedexMode
    @nameCommands=[
       _INTL("Don't specify"),
       _INTL("ABC"),_INTL("DEF"),_INTL("GHI"),
       _INTL("JKL"),_INTL("MNO"),_INTL("PQR"),
       _INTL("STU"),_INTL("VWX"),_INTL("YZ")
    ]
    @typeCommands=[
       _INTL("None"),
       _INTL("Normal"),_INTL("Fighting"),_INTL("Flying"),
       _INTL("Poison"),_INTL("Ground"),_INTL("Rock"),
       _INTL("Bug"),_INTL("Ghost"),_INTL("Steel"),
       _INTL("Fire"),_INTL("Water"),_INTL("Grass"),
       _INTL("Electric"),_INTL("Psychic"),_INTL("Ice"),
       _INTL("Dragon"),_INTL("Dark"),_INTL("Fairy")
    ]
    @colorCommands=[
       _INTL("Don't specify"),
       _INTL("Red"),_INTL("Blue"),_INTL("Yellow"),
       _INTL("Green"),_INTL("Black"),_INTL("Brown"),
       _INTL("Purple"),_INTL("Gray"),_INTL("White"),_INTL("Pink")
    ]
    @orderCommands=[
       _INTL("Numeric Mode"),
       _INTL("A to Z Mode"),
       _INTL("Heaviest Mode"),
       _INTL("Lightest Mode"),
       _INTL("Tallest Mode"),
       _INTL("Smallest Mode")
    ]
    @orderHelp=[
       _INTL("Pokémon are listed according to their number."),
       _INTL("Spotted and owned Pokémon are listed alphabetically."),
       _INTL("Owned Pokémon are listed from heaviest to lightest."),
       _INTL("Owned Pokémon are listed from lightest to heaviest."),
       _INTL("Owned Pokémon are listed from tallest to smallest."),
       _INTL("Owned Pokémon are listed from smallest to tallest.")
    ]
    @sprites["searchlist"].index=1
    searchlist=@sprites["searchlist"]
    @sprites["messagebox"].visible=true
    @sprites["auxlist"].visible=true
    @sprites["searchlist"].visible=true
    @sprites["searchbg"].visible=true
    @sprites["searchtitle"].visible=true
    tts("Search Menu: Select a parameter to change it") ### MODDED
    pbRefreshDexSearch(params)
    pbFadeInAndShow(@sprites)
    pbActivateWindow(@sprites,"searchlist"){
       loop do
         Graphics.update
         Input.update
         oldindex=searchlist.index
         pbUpdate
         if searchlist.index==0
           if oldindex==9 && Input.trigger?(Input::DOWN)
             searchlist.index=1
           elsif oldindex==1 && Input.trigger?(Input::UP)
             searchlist.index=9
           else
             searchlist.index=1
           end
         elsif searchlist.index==7
           if oldindex==8
             searchlist.index=6
           else
             searchlist.index=8
           end
         end
         if searchlist.index!=oldindex
           pbRefreshDexSearch(params)
         end
         if Input.trigger?(Input::C)
           pbPlayDecisionSE()
           command=searchlist.indexToCommand(searchlist.index)
           if command==[2,0]
             break
           end
           if command==[0,0]
             params[0]=pbDexSearchCommands(@nameCommands,params[0])
             pbRefreshDexSearch(params)
           elsif command==[0,1]
             params[1]=pbDexSearchCommands(@colorCommands,params[1])
             pbRefreshDexSearch(params)
           elsif command==[0,2]
             params[2]=pbDexSearchCommands(@typeCommands,params[2])
             pbRefreshDexSearch(params)
           elsif command==[0,3]
             params[3]=pbDexSearchCommands(@typeCommands,params[3])
             pbRefreshDexSearch(params)
           elsif command==[0,4]
             params[4]=pbDexSearchCommands(@orderCommands,params[4],@orderHelp)
             pbRefreshDexSearch(params)
           elsif command==[0,5]
             dexlist=pbSearchDexList(params)
             if dexlist.length==0
               Kernel.pbMessage(_INTL("No matching Pokémon were found."))
             else
               @dexlist=dexlist
               @sprites["pokedex"].commands=@dexlist
               @sprites["pokedex"].index=0
               @sprites["pokedex"].refresh
               iconspecies=@sprites["pokedex"].species
               if $Trainer.pokedex.dexList[iconspecies][:seen?]
                 lastGender = $Trainer.pokedex.dexList[iconspecies][:lastSeen][:gender]
                 lastForm = $Trainer.pokedex.dexList[iconspecies][:lastSeen][:form]
                 lastShiny = $Trainer.pokedex.dexList[iconspecies][:lastSeen][:shiny]
               else
                 iconspecies=nil 
                 lastGender = nil
                 lastForm = nil
                 lastShiny = false
               end
               monbitmap = pbPokemonBitmap(iconspecies,lastShiny,false,lastGender,lastForm)
              if monbitmap
                if iconspecies == :EXEGGUTOR && lastForm == "Alolan Form"
                  croppedBMP = Bitmap.new(192,192)
                  croppedBMP.blt(0,0,monbitmap,croppedBMP.rect)
                  monbitmap = croppedBMP
                end
                @sprites["icon"].bitmap = monbitmap
                @sprites["icon"].ox=@sprites["icon"].bitmap.width/2
                @sprites["icon"].oy=@sprites["icon"].bitmap.height/2
              end
               if iconspecies!=nil
                 @sprites["species"].text=_ISPRINTF("<ac>{1:s}</ac>",getMonName(iconspecies))
               else
                 @sprites["species"].text=_ISPRINTF("")
               end
               seenno=$Trainer.pokedex.getSeenCount
               ownedno=$Trainer.pokedex.getOwnedCount
               @sprites["seen"].text=_ISPRINTF("Seen:<r>{1:d}",seenno)
               @sprites["owned"].text=_ISPRINTF("Owned:<r>{1:d}",ownedno)
               dexname=_INTL("Pokédex")
               if $PokemonGlobal.pokedexUnlocked.length>1
                 thisdex=pbDexNames[pbGetSavePositionIndex]
                 if thisdex!=nil
                   if thisdex.is_a?(Array)
                     dexname=thisdex[0]
                   else
                     dexname=thisdex
                   end
                 end
               end
               @sprites["dexname"].text=_ISPRINTF("<ac>{1:s} - Search results</ac>",dexname)
               # Update the slider
               ycoord=62
               if @sprites["pokedex"].itemCount>1
                 ycoord+=188.0 * @sprites["pokedex"].index/(@sprites["pokedex"].itemCount-1)
               end
               @sprites["slider"].y=ycoord
               @searchResults=true
               break
             end
           elsif command==[1,0]
             params[5]=pbDexSearchCommands(@orderCommands,params[5],@orderHelp)
             pbRefreshDexSearch(params)
           elsif command==[1,1]
             $PokemonGlobal.pokedexMode=params[5]
             $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]=0
             pbRefreshDexList
             break
           end
         elsif Input.trigger?(Input::B)
           pbPlayCancelSE()
           break
         end
       end
    }
    pbFadeOutAndHide(@sprites)
    pbFadeInAndShow(@sprites,oldsprites)
    Input.update
    return 0
  end


  def pbPokedex
    pbActivateWindow(@sprites,"pokedex"){
       ### MODDED/
       iconspecies=@sprites["pokedex"].species
      if iconspecies.nil?
        tts("#{@sprites["pokedex"].index + 1}: Unknown")
      else
        tts("#{$cache.pkmn[iconspecies].dexnum}: #{getMonName(iconspecies)}")
      end
      ### /MODDED
       loop do
         Graphics.update
         Input.update
         oldindex=@sprites["pokedex"].index
         pbUpdate
         if oldindex!=@sprites["pokedex"].index
           $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]=@sprites["pokedex"].index if !@searchResults
           iconspecies=@sprites["pokedex"].species
           if $Trainer.pokedex.dexList[iconspecies][:seen?]
             lastGender = $Trainer.pokedex.dexList[iconspecies][:lastSeen][:gender]
             lastForm = $Trainer.pokedex.dexList[iconspecies][:lastSeen][:form]
             lastShiny = $Trainer.pokedex.dexList[iconspecies][:lastSeen][:shiny]
           else
             iconspecies=nil 
             lastGender = nil
             lastForm = nil
             lastShiny = false
           end
           monbitmap = pbPokemonBitmap(iconspecies,lastShiny,false,lastGender,lastForm)
            if monbitmap
              if iconspecies == :EXEGGUTOR && lastForm == "Alolan Form"
                croppedBMP = Bitmap.new(192,192)
                croppedBMP.blt(0,0,monbitmap,croppedBMP.rect)
                monbitmap = croppedBMP
              end
              @sprites["icon"].bitmap = monbitmap
              @sprites["icon"].ox=@sprites["icon"].bitmap.width/2
              @sprites["icon"].oy=@sprites["icon"].bitmap.height/2
            else
              @sprites["icon"].bitmap = nil
            end
           if iconspecies != nil
             @sprites["species"].text=_ISPRINTF("<ac>{1:s}</ac>",getMonName(iconspecies))
           else
             @sprites["species"].text=_ISPRINTF("")
           end
           # Update the slider
           ycoord=62
           if @sprites["pokedex"].itemCount>1
             ycoord+=188.0 * @sprites["pokedex"].index/(@sprites["pokedex"].itemCount-1)
           end
           @sprites["slider"].y=ycoord
           ### MODDED/
          if iconspecies.nil?
            tts("#{@sprites["pokedex"].index + 1}: Unknown")
          else
            tts("#{$cache.pkmn[iconspecies].dexnum}: #{getMonName(iconspecies)}")
          end
          ### /MODDED
         end
         if Input.trigger?(Input::B)
           pbPlayCancelSE()
           if @searchResults
             pbCloseSearch
           else
             break
           end
         elsif Input.trigger?(Input::C)
           if $Trainer.pokedex.dexList[@sprites["pokedex"].species][:seen?]
             pbPlayDecisionSE()
             pbDexEntry(@sprites["pokedex"].index)
           ### MODDED/
          if iconspecies.nil?
            tts("#{@sprites["pokedex"].index + 1}: Unknown")
          else
            tts("#{$cache.pkmn[iconspecies].dexnum}: #{getMonName(iconspecies)}")
          end
          ### /MODDED
           end
         elsif Input.trigger?(Input::Y)
           pbPlayDecisionSE()
           pbDexSearch
           ### MODDED/
           iconspecies=@sprites["pokedex"].species
           if iconspecies.nil?
              tts("#{@sprites["pokedex"].index + 1}: Unknown")
            else
              tts("#{$cache.pkmn[iconspecies].dexnum}: #{getMonName(iconspecies)}")
            end
          ### /MODDED
         end
       end
    }
  end
end

class AdvancedPokedexScene

   def pageInfo(page)
    @sprites["overlay"].bitmap.clear
    textpos = []
    for i in (12*(page-1))...(12*page)
      line = i%6
      column = i/6
      next if !@infoArray[column][line]
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*line
      tts(@infoArray[column][line]) ### MODDED
      textpos.push([@infoArray[column][line],x,y,false,BASECOLOR,SHADOWCOLOR])
    end
     pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end  
   
   def pageMoves(movesArray,label,page)
    @sprites["overlay"].bitmap.clear
    tts(label)
    textpos = [[label,BASE_X,BASE_Y,false,BASECOLOR,SHADOWCOLOR]]
     for i in (10*(page-1))...(10*page)
      break if i>=movesArray.size
      line = i%5
      column = i/5
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*(line+1)
      tts(movesArray[i]) ### MODDED
      textpos.push([movesArray[i],x,y,false,BASECOLOR,SHADOWCOLOR])
    end
     pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end  
end

class PokedexForm
  def pbStartScreen(species, listlimits)
    @scene.pbStartScene(species)
    tts("Sprite View: #{getMonName(species)}")
    ret = @scene.pbControls(listlimits)
    @scene.pbEndScene
    return ret
  end
end

