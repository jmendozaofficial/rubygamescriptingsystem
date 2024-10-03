#◆◇◆◇◆◇◆◇◆◇  Picture Bind  ◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇
#  A way to bind pictures to the map below or above) and fixed.
#   by Tatsumi

# How to use:

#PICTURES THAT WOULD SHOW BELOW THE CHARACTERS

# If you want the pictures to be shown below the characters (or pictures
# that would show as the foreground or ground layer), take note of
# the F_PIC and L_PIC on the LayeredPicture module.

# For example, by default, F_PIC is 10 and L_PIC is 15. This means that
# if you made a show picture event and the number is 10, 11, 12, 13, 14
# or 15, they would all show below the characters and act as foreground.

# This means that pictures with the number 1, 2, 3, 4, 5, 6, 7, 8, 9, 11
# and so on would be shown above the character or in other words they 
# would be shown normally.

# FIXED PICTURES

# The pictures you show on screen actually has one behavior. It follows
# your character's movements. This means that when you showed the picture,
# it would follow your movement if you move. If you want the pictures
# to be on the same position or locked, you have to place [FIXED] on the
# image name.
#◆◇◆◇◆◇◆◇◆◇◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇
module Soul
    module LayeredPicture
      F_PIC = 10 # First Picture
      L_PIC = 15 # Last Picture
    end
  end
  
  class Sprite_Picture < Sprite
    def update
      update_bitmap
      update_origin
      if @picture.name.include?("[FIXED]")
        self.x = 0 - $game_map.display_x * 32
        self.y = 0 - $game_map.display_y * 32
      else
        update_position
      end
      update_zoom
      update_other
    end
  end
  
  class Spriteset_Map
    include Soul::LayeredPicture
    #--------------------------------------------------------------------------
    # ● Alias Listings
    #--------------------------------------------------------------------------  
    unless method_defined?(:soul_layered_picture_initialize)
      alias_method(:soul_layered_picture_initialize, :initialize)
    end  
    unless method_defined?(:soul_layered_picture_dispose)
      alias_method(:soul_layered_picture_dispose, :dispose)
    end    
    #--------------------------------------------------------------------------
    # ● Initialize
    #--------------------------------------------------------------------------  
    def initialize
      soul_layered_picture_initialize
      for i in F_PIC..L_PIC
        @picture_sprites[i-1] = Sprite_Picture.new(@viewport1, $game_map.screen.pictures[i])
      end    
    end
    #--------------------------------------------------------------------------
    # ● Dispose
    #--------------------------------------------------------------------------
    def dispose
      soul_layered_picture_dispose
      for i in F_PIC..L_PIC
        @picture_sprites[i-1].dispose
      end 
    end  
  end
  
  class Sprite_Picture < Sprite
    include Soul::LayeredPicture
    #---------------------------------------------------------------------------
    # * Alias Listings
    #---------------------------------------------------------------------------
    unless method_defined?(:soul_layered_picture_update)
      alias_method(:soul_layered_picture_update, :update)
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    def update
      soul_layered_picture_update
      self.z = 1 if (@picture.number >= F_PIC and @picture.number <= L_PIC)
    end
  end
  
  