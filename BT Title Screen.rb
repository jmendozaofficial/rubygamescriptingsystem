class Window_TitleCommand < Window_Command
    def col_max
      return 3
    end
  end
  
  module Math
    
    # Convert degree to radian
    def self.radian(degree)
      return (degree.to_f/180) * Math::PI
    end
  
  end
  
  class Particle < Sprite
    @@degree = 90
    @@method = [:sin, :cos]
    @@bitmap = nil
    
    def initialize
      super
      unless @@bitmap
        @@bitmap = Bitmap.new(3,3)
        @@bitmap = Cache.title2('Particle')
      end
      self.bitmap = @@bitmap
      self.ox = width/2
      self.oy = height/2
      @degree = @@degree
      @@degree = rand(360)  
      @radius = rand(5) + 10
      @x = 0#Graphics.width/2
      @y = 0#Graphics.height/2
      @x_method = @@method[0]
      @y_method = @@method[1]
      @timeout = 750
      temp = @@method[0]
      @@method[0] = @@method[1]
      @@method[1] = temp
      update_position
    end
    
    def update_position
      self.x = @x
      self.y = @y
    end
    
    def update
      super
      @timeout -= 1
      update_spread
    end
    
    def update_spread
      @degree += 1
      speed = Math.cos(Math.radian(@degree)) * @radius
      @x += Math.method(@x_method).call(Math.radian(@degree)) * speed
      @y += Math.method(@y_method).call(Math.radian(@degree)) * speed
      update_position
    end
    
    def out?
      !self.x.between?(0,Graphics.width) || !self.y.between?(0,Graphics.height) ||
      @timeout == 0
    end
    
  end
  
  class Particles
    
    def initialize
      @sprites = []
      @time_span = 0
    end
    
    def update
      if @time_span == 0
        @sprites << Particle.new
  #~       @sprites << Particle.new
        @time_span = 1
      else
        @time_span -= 1
      end
      @sprites.delete_if do |spr|
        spr.update
        spr.dispose if spr.out?
        spr.disposed?
      end
    end
    
  end
  
  
  
  
  
  module Sound
    
    #Confirm
    def self.play_ok
      if SceneManager.scene.is_a?(Scene_Title)
        RPG::SE.new("Confirm on Title", 100, 100).play
      else 
        play_system_sound(1)
      end
    end
    
    # Cursor Movement
    def self.play_cursor
      if SceneManager.scene.is_a?(Scene_Title)
        RPG::SE.new("Menu1A", 100, 100).play
      else
        play_system_sound(0)
      end
    end
    
    
    # Cancel
    def self.play_cancel
      if SceneManager.scene.is_a?(Scene_Load)
        RPG::SE.new("Cancel on Title", 100, 100).play
      else
        play_system_sound(2)
      end
      
    end  
    
  end
  
  class Title_Particle < Sprite
    attr_reader :done
    def initialize
      super(nil)
      self.bitmap = $title_particle
      self.x = 115
      self.y = 310
      self.blend_type = 1
      self.ox = self.bitmap.width/2
      self.oy = self.bitmap.height/2
      self.angle = rand(360)
      self.z = 200
      @add = rand(5)
      @burn = 5+rand(15)
      @done = false
    end
    def update
      self.y -= 1
      self.opacity -= @burn
      self.angle += @add
      dispose if self.opacity <= 0
    end
    def dispose
      self.bitmap = nil
      super
      @done = true
    end
  end
  
  module Cache
    #--------------------------------------------------------------------------
    # ● アニメーション グラフィックの取得
    #--------------------------------------------------------------------------
    def self.particle(filename)
      load_bitmap("Graphics/Particles/", filename)
    end
    
  end
  
  
  class Scene_Title < Scene_Base
    alias title_start start
    #--------------------------------------------------------------------------
    # * Start Processing
    #--------------------------------------------------------------------------
    def start
      title_start
      @number_of_frames = 0
      create_command_images
      create_arrows
      create_logo
      create_blade_image
      create_burn_particle
      create_particle_motion_x
      create_flat_layer
      @phase = 0
      @start_burn = false
      @wait_time = 0
      @finish_phase = false
      @stop_se_play = false
      @stop_shot_play = false
      @foregrounds = ['Foreground2']
      @arrowlist = ['Arrow1', 'Arrow2', 'Arrow3', 'Arrow4']
      @action_countdown = 0
      @foreground_count = 0
      @foreground_count_max = @foregrounds.size
      @title_music_start = false
      create_arrow_shot
      @arrow_shot_sound_wait = 0
    end  
    
    def create_arrow_shot
      @arrow_shot = Sprite.new
      @arrow_shot.x = 0
      @arrow_shot.y = 110
      @phase2 = 0
      @wait_time2 = 0
      @finish_phase2 = false
      @arrow_shot.z = 200
    end
    
    
    #--------------------------------------------------------------------------
    # * Play Title Screen Music
    #--------------------------------------------------------------------------
    def play_title_music
      if @title_music_start
        $data_system.title_bgm.play
      end
      RPG::BGS.stop
      RPG::ME.stop
    end  
    
    def create_particle_motion_x
      @particle_pier_solar = Particles.new
    end
    
    def create_burn_particle
      $title_particle = Cache.particle("")
      @particles = []
      @trash = []
    end
    
    def update_burn_particle
      if @start_burn
        $title_particle = Cache.particle("purplefire")
      end
      3.times do; @particles << Title_Particle.new; end
      @particles.each { |particle| particle.update; @trash << particle if particle.done }
      @trash.each { |item| @particles.delete(item) }
      @trash.clear    
    end
    
    def terminate_burn_particle
      @particles.each { |particle| particle.dispose }
      @particles.clear
      $title_particle= nil
      @particles = nil 
    end
    
    
    def create_blade_image
      @blade = Sprite.new
      @blade.bitmap = Cache.title2('Blade')
      @blade.x = -50
      @blade.y = -1200
    end
    
    def create_flat_layer
      @flat_layer = Sprite.new
      @flat_layer.opacity = 0
    end
    
    
    def move_blade_image
      if @blade.y <= 155
        @blade.y += 35
      else 
        @start_burn = true
        @title_music_start = true
        
      end
      if @blade.y == 165
        @se_play = true
        @confirm_action = true
      end
    end
    
    
    def create_logo
      @logo = Sprite.new
      @logo.x = 190
      @logo.opacity = 0
    end
    
    
    
    def create_command_images
      @command_image = Sprite.new
      @command_image.x = -170
      @command_image.opacity = 0
      @command_image.z = 120
    end
    
  
    
    def create_arrows
      @arrowx_1 = Sprite.new
      
      @arrowx_1.x = 100
      @arrowx_1.y = 410    
      @arrowx_2 = Sprite.new
        
      @arrowx_2.x = 460
      @arrowx_2.y = 410
    end
    
    
    #--------------------------------------------------------------------------
    # * [New Game] Command
    #--------------------------------------------------------------------------
    def command_new_game
      @confirm_actionX = true
      fadeout_all
      DataManager.setup_new_game
      close_command_window
      $game_map.autoplay
      SceneManager.goto(Scene_Map)
    end
    #--------------------------------------------------------------------------
    # * [Continue] Command
    #--------------------------------------------------------------------------
    def command_continue
      close_command_window
      SceneManager.call(Scene_Load)
    end
    #--------------------------------------------------------------------------
    # * [Shut Down] Command
    #--------------------------------------------------------------------------
    def command_shutdown
      close_command_window
      fadeout_all
      SceneManager.exit
    end  
    
    #--------------------------------------------------------------------------
    # * Create Background
    #--------------------------------------------------------------------------
    def create_background
  
      @sprite0 = Plane.new
      
      @sprite4 = Sprite.new
      
      @sprite4.opacity = 0
      @particleX1 = Plane.new
          
      @particleX2 = Plane.new
      @particleX2.opacity = 0
      @particleX3 = Plane.new
      @particleX3.opacity = 0
      @sprite1 = Plane.new
      @sprite1.opacity = 0
      @sprite2 = Sprite.new
      @sprite2.opacity = 0
      
    end
    
    
    def update_arrow_shot
      if @confirm_action
        
        if @finish_phase2 != true
          if @phase2 != @arrowlist.size
            if @arrow_shot.opacity != 255
              @arrow_shot.opacity = 255
            else
              if @wait_time2 != 1
                @wait_time2 += 1
              else
                if @phase2 < @arrowlist.size-1
                   
                  if @phase2 >= @arrowlist.size
                    @phase2 = 0
                  else
                    @phase2 = @phase2 + 1
                  end
                  
                  @arrow_shot.opacity = 0 
                else
                  @finish_phase2 = true
                  @arrow_shot.opacity = 255
                end
                @arrow_shot.bitmap = Cache.title2(@arrowlist[@phase2])
                @wait_time2 = 0
              end
            end
          else
            @finish_phase2 = true
          end
        end
        @arrow_shot.bitmap = Cache.title2(@arrowlist[@phase2])    
      end  
    end
    
    
    #--------------------------------------------------------------------------
    # * Termination Processing
    #--------------------------------------------------------------------------
    def terminate
      super
      terminate_burn_particle
      SceneManager.snapshot_for_background
      dispose_background
      dispose_foreground
      @command_image.bitmap.dispose
      @command_image.dispose
      @sprite0.bitmap.dispose
      @sprite0.dispose
      @particleX1.bitmap.dispose
      @particleX1.dispose    
      @particleX2.bitmap.dispose
      @particleX2.dispose  
      @particleX3.bitmap.dispose
      @particleX3.dispose   
      @logo.bitmap.dispose
      @logo.dispose
      @blade.bitmap.dispose
      @blade.dispose
      @arrow_shot.bitmap.dispose
      @arrow_shot.dispose
      @start_burn = false
      @se_play = false
    end  
    
    def update
      super
      play_title_music if !@confirm_actionX
      if @start_burn
        @command_window.activate
      else
        @command_window.deactivate
      end
  
        if @particleX1.opacity < 255
          if @start_burn
            @particleX1.opacity += 2
          end
        end  
      
        if @particleX2.opacity < 255
          if @start_burn
            @particleX2.opacity += 2
          end
        end       
        
        if @particleX3.opacity < 255
          if @start_burn
            @particleX3.opacity += 2
          end
        end      
        
        if @sprite2.opacity < 255
          if @start_burn
            @sprite2.opacity += 10
          end
        end        
       
        if @sprite1.opacity < 255
          if @start_burn
            @sprite1.opacity += 2
          end
        end  
           
        
      if @start_burn
        @sprite2.bitmap = Cache.title2($data_system.title2_name)
        @sprite1.bitmap = Cache.title1($data_system.title1_name)   
        @particleX3.bitmap = Cache.title1('Title-Sparkle03')  
        @particleX2.bitmap = Cache.title1('Title-Sparkle02')
        @particleX1.bitmap = Cache.title1('Title-Sparkle01')
        @sprite4.bitmap = Cache.title1('Foreground3') 
        @sprite0.bitmap = Cache.title1('Foreground2')
      end
      
      if @arrow_shot_sound_wait <= 5
        @arrow_shot_sound_wait += 2 if @start_burn
      else
        @se_play2 = true
      end
      
      if @flat_layer.opacity < 255
        if @start_burn
          @flat_layer.opacity += 5
        end
      end
      
      
      
      update_burn_particle
      move_blade_image
      update_arrow_shot
      if @start_burn
        if @finish_phase != true
          if @phase != @foregrounds.size
            if @sprite4.opacity != 255
              @sprite4.opacity += 1
            else
              if @wait_time != 300
                @wait_time += 1
              else
                if @phase < @foregrounds.size-1
                   
                  if @phase >= @foregrounds.size
                    @phase = 0
                  else
                    @phase = @phase + 1
                  end
                  
                  @sprite4.opacity = 0 
                else
                  @finish_phase = true
                  @sprite4.opacity = 255
                end
                @sprite4.bitmap = Cache.title1(@foregrounds[@phase])
                @wait_time = 0
              end
            end
          else
            @finish_phase = true
          end
        end
        @sprite4.bitmap = Cache.title1(@foregrounds[@phase])    
      end
        if @se_play && !@stop_se_play
          RPG::SE.new('Sword4', 100, 100).play
          @se_play = false
          @stop_se_play = true
        end
        if @se_play2 && !@stop_shot_play
          RPG::SE.new('Arrow Shot', 100, 100).play
          @se_play = false
          @stop_shot_play = true
        end
      if @sprite4.opacity < 255
        @sprite4.opacity += 10
      else
        @sprite4.opacity = 255
      end
      
      if @command_window.index == 0
        @flat_layer.bitmap = Cache.title2('Flat_Layer1')
      end
      if @command_window.index == 1
        @flat_layer.bitmap = Cache.title2('Flat_Layer2')
      end
      if @command_window.index == 2
        @flat_layer.bitmap = Cache.title2('Flat_Layer3')
      end    
      
      if @start_burn
        @logo.bitmap = Cache.title1('Logo')
      end
      
      @command_window.visible = false
      if @number_of_frames < 5
        @number_of_frames += 1
      else
        @number_of_frames = 0
        @sprite1.ox += 1
      @particleX1.ox += 1
      @particleX1.oy += 1      
      @particleX2.ox -= 1
      @particleX2.oy -= 1
      @particleX3.ox += 1
      @particleX3.oy -= 1
      end
  #~    @logo.y = 10 + @logo.height / 2 - @logo.height / 2 + Math.sin(Time.now.to_f) * 10
        if @command_image.opacity < 255
          @command_image.opacity += 10
        end
        if @logo.opacity < 255
          if @start_burn
            @logo.opacity += 10
          end
        end      
      if @command_window.index == 0
        if @start_burn
          @command_image.bitmap = Cache.title2('Com_1')
        end
            
      end
      if @command_window.index == 1
        if @start_burn
          @command_image.bitmap = Cache.title2('Com_2')
        end
      
      end
      if @command_window.index == 2
        if @start_burn
          @command_image.bitmap = Cache.title2('Com_3')
        end
      @arrowx_1.x = 155 + @arrowx_1.width / 2 - @arrowx_1.width / 2 + Math.sin(Time.now.to_f) * 10
      @arrowx_2.x = 420 + @arrowx_1.width / 2 - @arrowx_1.width / 2 - Math.sin(Time.now.to_f) * 10         
      end
      if Input.trigger?(:LEFT)
        if @command_window.index != 0 && @command_window.index != 2
          @command_image.opacity = 0  
        end
      end
      if Input.trigger?(:RIGHT)
        if @command_window.index != 0 && @command_window.index != 2
          @command_image.opacity = 0  
        end
      end
      @particle_pier_solar.update
    end
    
  end
  