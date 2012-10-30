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
	
	#~ INVULNERABLE_DURATION = 350
	INVULNERABLE_DURATION = 24
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
			self.x = object.x - ($window.width/2) / 2
			self.y = object.y - ($window.height/2) / 2
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
end

module Chingu
  module Traits
    module Timer
      #
      # Executes block each update during 'time' milliseconds
      #
      def during(time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = $window.frame # Gosu::milliseconds()
        @_last_timer = [options[:name], ms, ms + time, block]
        @_timers << @_last_timer
        self
      end
      
      #
      # Executes block after 'time' milliseconds
      #
      def after(time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = $window.frame # Gosu::milliseconds()
        @_last_timer = [options[:name], ms + time, nil, block]
        @_timers << @_last_timer
        self
      end

      #
      # Executes block each update during 'start_time' and 'end_time'
      #
      def between(start_time, end_time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = $window.frame # Gosu::milliseconds()
        @_last_timer = [options[:name], ms + start_time, ms + end_time, block]
        @_timers << @_last_timer
        self
      end

      #
      # Executes block every 'delay' milliseconds
      #
      def every(delay, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end
        
        ms = $window.frame # Gosu::milliseconds()
        @_repeating_timers << [options[:name], ms + delay, delay, options[:during] ? ms + options[:during] : nil, block]
        if options[:during]
          @_last_timer = [options[:name], nil, ms + options[:during]]
          return self
        end
      end

      #
      # Executes block after the last timer ends
      # ...use one-shots start_time for our trailing "then".
      # ...use durable timers end_time for our trailing "then".
      #
      def then(&block)
        start_time = @_last_timer[2].nil? ? @_last_timer[1] : @_last_timer[2]
        @_timers << [@_last_timer[0], start_time, nil, block]
      end


      #
      # See if a timer with name 'name' exists
      #
      def timer_exists?(timer_name = nil)
        return false if timer_name.nil?
        @_timers.each { |name, | return true if timer_name == name }
        @_repeating_timers.each { |name, | return true if timer_name == name }
        return false
      end

      #
      # Stop timer with name 'name'
      #
      def stop_timer(timer_name)
        @_timers.reject! { |name, start_time, end_time, block| timer_name == name }
        @_repeating_timers.reject! { |name, start_time, end_time, block| timer_name == name }
      end
      
      #
      # Stop all timers
      #
      def stop_timers
        @_timers.clear
        @_repeating_timers.clear
      end
      
      def update_trait
        ms = $window.frame # Gosu::milliseconds()
        
        @_timers.each do |name, start_time, end_time, block|
          block.call if ms > start_time && (end_time == nil || ms < end_time)
        end
                
        index = 0
        @_repeating_timers.each do |name, start_time, delay, end_time, block|
          if ms > start_time
            block.call  
            @_repeating_timers[index] = [name, ms + delay, delay, end_time, block]
          end
          if end_time && ms > end_time
            @_repeating_timers.delete_at index
          else
            index += 1
          end
        end

        # Remove one-shot timers (only a start_time, no end_time) and all timers which have expired
        @_timers.reject! { |name, start_time, end_time, block| (ms > start_time && end_time == nil) || (end_time != nil && ms > end_time) }
      
        super
      end
      
    end
  end
end
