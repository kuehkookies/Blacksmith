# ------------------------------------------------------
# Modules
# modules needed for the game
# ------------------------------------------------------

module Module_Game
	module Environment
		GRAV_CAP = 8
		GRAV_ACC = 0.4
		GRAV_WHEN_LAND = 1
		#~ GRAV_CAP = 16
		#~ GRAV_ACC = 0.8
		#~ GRAV_WHEN_LAND = 1
	end
	
	INVULNERABLE_DURATION = 350
	ALLOWED_SUBWEAPON_THROWN = 1

	BGM =[
		#~ "silence-of-daylight",
		"level03-binding",
		"Gears_and_Chains"
	]
end

module Chingu
	class GameObjectList
		def grep(*object)
			result = @game_objects.grep(*object)
			return result
		end
		def subtract_with(object)
			@game_objects -= object
		end
	end

	class Viewport
		def center_around(object)
			#~ self.x = object.x - ($window.width - 272) / 2
			#~ self.y = object.y - ($window.height - 208) / 2
			self.x = object.x - ($window.width/2) / 2
			self.y = object.y - ($window.height/2) / 2
			#~ self.x = object.x - $window.width / 2
			#~ self.y = object.y - $window.height / 2
		end
		def x=(x)
			@x = x
			if @game_area
				@x = @game_area.x                     if @x < @game_area.x
				@x = @game_area.width-$window.width/2   if @x > @game_area.width-$window.width/2
			end 
		end

		def y=(y)
			@y = y
			if @game_area
				@y = @game_area.y                       if @y < @game_area.y
				@y = @game_area.height-$window.height/2   if @y > @game_area.height-$window.height/2
			end
		end
	end
	#~ module Traits
		#~ module Timer
			#~ def update_trait
				#~ ms = Gosu::milliseconds()
				
				#~ @_timers.each do |name, start_time, end_time, block|
				  #~ block.call if ms > start_time && (end_time == nil || ms < end_time) # and !$window.paused
				#~ end
						
				#~ index = 0
				#~ @_repeating_timers.each do |name, start_time, delay, end_time, block|
				  #~ if ms > start_time
					#~ block.call  
					#~ @_repeating_timers[index] = [name, ms + delay, delay, end_time, block]
				  #~ end
				  #~ if end_time && ms > end_time
					#~ @_repeating_timers.delete_at index
				  #~ else
					#~ index += 1
				  #~ end
				#~ end

				#~ # Remove one-shot timers (only a start_time, no end_time) and all timers which have expired
				#~ @_timers.reject! { |name, start_time, end_time, block| (ms > start_time && end_time == nil) || (end_time != nil && ms > end_time) }
		  
			#~ super
		  #~ end
		  
		#~ end
	#~ end	
end