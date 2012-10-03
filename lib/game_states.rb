# ------------------------------------------------------
# Game States
# Handles special game state i.e. pause or
# transition between blocks
# ------------------------------------------------------
class Pause < GameState
	def initialize(options={})
		super
		self.input = {:space => :unpause}
		@color = Color.new(0x77000000)
	end
	def draw
		previous_game_state.draw
		$window.draw_quad(  0,0,@color,
										$window.width,0,@color,
										$window.width,$window.height,@color,
										0,$window.height,@color, Chingu::DEBUG_ZORDER)
	end
	def unpause
		pop_game_state(:setup => false)
	end
end

class Pause_Event < GameState
	traits :timer
	def initialize(options={}); super; end
	def draw
		previous_game_state.draw
		# after(500){ pop_game_state(:setup => false) }
	end
	def update
		after(500){ pop_game_state(:setup => false) }
	end
end

class Zero < GameState
	traits :timer
	
	def initialize(options={})
		super
		@color = Color.new(0xFF000000)
	end
	def draw
		$window.draw_quad(  0,0,@color,
										$window.width,0,@color,
										$window.width,$window.height,@color,
										0,$window.height,@color, Chingu::DEBUG_ZORDER)
	end
	def update
		after(50){ 
			if $window.hp <= 0
				$window.setup_player
				pop_game_state(:setup => false)
			else
				pop_game_state(:setup => false)
			end 
		}
	end
end

class DeathFlash < GameState
	traits :timer
	
	def initialize(options={})
		super
		@color = Color.new(0x44882222)
	end
	def draw
		$window.draw_quad(  0,0,@color,
										$window.width,0,@color,
										$window.width,$window.height,@color,
										0,$window.height,@color, Chingu::DEBUG_ZORDER)
	end
	def update
		after(100){ pop_game_state(:setup => false) }
	end
end


class Transitional < Chingu::GameState
      
	def initialize(new_game_state, options = {})
		super(options)
		@options = {:speed => 3, :zorder => INFINITY}.merge(options)
		
		@new_game_state = new_game_state
		@new_game_state = new_game_state.new if new_game_state.is_a? Class        
		p @new_game_state
	end

	def setup
		@color = Gosu::Color.new(0,0,0,0)
		if previous_game_state
			p "* Setup: fading out"   if options[:debug]
			@fading_in = false
			@alpha = 0.0
		else
			p "* Setup: fading in"    if options[:debug]
			@fading_in = true 
			@alpha = 255.0
		end
		
		update                        # Since draw is called before update
	end

	def update
		@alpha += (@fading_in ? -@options[:speed] : @options[:speed])
		@alpha = 0    if @alpha < 0
		@alpha = 255  if @alpha > 255
		
		if @alpha == 255
			@fading_in = true
			p "* Update: fading in"    if options[:debug]
		end
		
		@color.alpha = @alpha.to_i
		@drawn = false
	end
	
	def draw
		# Stop possible endless loops
		if @drawn == false
			@drawn = true
			
			if @fading_in
				@new_game_state.draw unless @new_game_state == nil
			else
				previous_game_state.draw
			end
	
			$window.draw_quad( 0,0,@color,
													$window.width,0,@color,
													$window.width,$window.height,@color,
													0,$window.height,@color,@options[:zorder])
		end
		
		if @fading_in && @alpha == 0
			switch_game_state(@new_game_state, :transitional => false)
		end
												
	end
end