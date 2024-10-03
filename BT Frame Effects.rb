class Scene_Map < Scene_Base
    attr_accessor :fog
    attr_accessor :visible
    attr_accessor :mist
    def start
      super
      SceneManager.clear
      $game_player.straighten
      $game_map.refresh
      $game_message.visible = false
      create_spriteset
      create_all_windows
      @menu_calling = false
      make_fog
    end
    
    def make_fog
      #make fog sprite
      @fs = Plane.new
      @fs.bitmap=Cache.picture("Fog")
      @fs2 = Plane.new
      @fs2.bitmap=Cache.picture("Fog")
      @fs3 = Plane.new
      @fs3.bitmap=Cache.picture("Fog")
      
      @fs.opacity=0
      @fs2.opacity=0
      @fs3.opacity=0
      
      @fs.blend_type=0
      @fs2.blend_type=1
      @fs3.blend_type=2
      
      @bd1 = Sprite.new
      @bd1.bitmap=Cache.picture("black_border")
      @bd1.z = 190
      @bd2 = Sprite.new
      @bd2.bitmap=Cache.picture("black_border")
      @bd2.z = 190
      @bd1.y=0
      @bd2.y=480+56
      @bd1.oy=56
      @bd2.oy=56
      
      @mist = Sprite.new
      @mist.bitmap=Cache.picture("mist")
      @mist.wave_amp=150
      @mist.wave_length=250
      @mist.wave_speed=1000
      @mist.blend_type=1
      @mist.ox=150
      @mist.oy=150
      @mist.x=0
      @mist.y=0
      @mist.opacity=0
      
    end
    
    #--------------------------------------------------------------------------
    # * Termination Processing
    #--------------------------------------------------------------------------
    def terminate
      super
      $fog = 0
      $mist = 0
      SceneManager.snapshot_for_background
      dispose_spriteset
      perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
    end  
    
    def update
    super
      $game_map.update(true)
      $game_player.update
      $game_timer.update
      @spriteset.update
      update_scene if scene_change_ok?
      if $fog==1
        if @fs.opacity < 255
          @fs.opacity += 255/60
        end
      end
      if $fog==0
        if @fs.opacity>0
          @fs.opacity-=255/30
        end
      end
      @fs2.opacity=@fs.opacity
      @fs3.opacity=@fs.opacity
      @fs.ox+=1
      @fs2.ox+=2
      @fs2.oy+=1
      @fs3.oy+=2
      
      if $cutscene==1
        if @bd1.y<56
          @bd1.y+=2
          @bd2.y-=2
        end
      end
      if $cutscene==0
        if @bd1.y>0
          @bd1.y-=2
          @bd2.y+=2
        end
      end
      if $mist==1
        @mist.opacity=255
      end
      if $mist==0
        @mist.opacity=0
      end
      @mist.update
      
    end
  end