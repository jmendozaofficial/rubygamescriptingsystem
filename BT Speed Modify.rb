class Game_CharacterBase
    alias soulxregalia_init_public_members init_public_members
    #--------------------------------------------------------------------------
    # * Initialize Public Member Variables
    #--------------------------------------------------------------------------
    def init_public_members
      soulxregalia_init_public_members
      @move_speed = 5
    end
  end
  
  class Game_Player < Game_Character
    alias get_off_vehicle_x get_off_vehicle
    #--------------------------------------------------------------------------
    # * Get Off Vehicle
    #    Assumes that the player is currently riding in a vehicle.
    #--------------------------------------------------------------------------
    def get_off_vehicle
      get_off_vehicle_x
      @move_speed = 5
    end
  end
  
  class Game_Vehicle < Game_Character
    #--------------------------------------------------------------------------
    # * Initialize Move Speed
    #--------------------------------------------------------------------------
    def init_move_speed
      @move_speed = 4 if @type == :boat
      @move_speed = 5 if @type == :ship
      @move_speed = 6 if @type == :airship
    end
  end
  