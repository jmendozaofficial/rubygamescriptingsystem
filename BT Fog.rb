#◆◇◆◇◆◇◆◇◆◇◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇
#  LS - Simple Fog
# Author: Tatsumi
#◆◇◆◇◆◇◆◇◆◇◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇◇◆◇◆◇
class Game_System
    attr_accessor :fogName
    attr_accessor :fogOpacity
    attr_accessor :fogX
    attr_accessor :fogY
    alias soulxregalia_gameSystem_initialize initialize
    def initialize
      soulxregalia_gameSystem_initialize
      @fogName = ""
      @fogOpacity = 0
      @fogX = 0
      @fogY = 0
    end
  end
  
  
  class Spriteset_Map
    alias soulxregalia_spritesetMap_initialize initialize
    alias soulxregalia_spritesetMap_update update
    alias soulxregalia_spritesetMap_dispose dispose
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize
      soulxregalia_spritesetMap_initialize
      create_fog_sprite
    end
    
    def create_fog_sprite
      @fogSprite = Plane.new
      @fogSprite.bitmap = Cache.picture($game_system.fogName)
      @fogSprite.opacity = $game_system.fogOpacity
      @fogSprite.z = 140
    end
    
    def update
      soulxregalia_spritesetMap_update
      @fogSprite.bitmap = Cache.picture($game_system.fogName) if @fogSprite
      @fogSprite.ox += $game_system.fogX if @fogSprite
      @fogSprite.oy += $game_system.fogY  if @fogSprite 
      @fogSprite.opacity = $game_system.fogOpacity if @fogSprite
    end
    
    #--------------------------------------------------------------------------
    # * Free
    #--------------------------------------------------------------------------
    def dispose
      soulxregalia_spritesetMap_dispose
      @fogSprite.bitmap.dispose
      @fogSprite.dispose
    end
    
  end
  