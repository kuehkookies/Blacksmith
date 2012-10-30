# ------------------------------------------------------
# Scenes
# What's happening in each blocks?
# ------------------------------------------------------
class Scene < GameState
	traits :viewport, :timer
	attr_reader :player, :terrain, :area, :backdrop, :hud

	def initialize
		super
		#~ self.input = { :escape => :exit, :e => :edit, :r => :restart, :space => Pause }
		self.input = { :escape => :exit, :e => :edit, :r => :restart, :space => :pause }
		@backdrop = Parallax.new(:rotation_center => :top_left, :zorder => 10)
		@area = [0,0]
		@tiles = []
		@recorded_tilemap = nil
		#~ @file = File.join(ROOT, "levels/#{self.class.to_s.downcase}.yml")
		@file = File.join(ROOT, "#{self.class.to_s.downcase}.yml")
		$window.clear_cache
		player_start
		@hud = HUD.create(:player => @player) # if @hud == nil
		@player.sword = nil
		clear_game_terrains
		clear_subweapon_projectile
		game_objects.select { |game_object| !game_object.is_a? Player }.each { |game_object| game_object.destroy }
		load_game_objects(:file => @file) unless self.class.to_s == "Zero"
		for i in 0..$window.terrains.size
			@tiles += game_objects.grep($window.terrains[i])
		end
		for i in 0..$window.bridges.size
			@tiles += game_objects.grep($window.bridges[i])
		end
		for i in 0..$window.decorations.size
			@tiles += game_objects.grep($window.decorations[i])
		end
		game_objects.subtract_with(@tiles)
		#~ after(350) { $window.stop_transferring }
		after(15) { $window.stop_transfer }
		#~ @song = Gosu::Song.new("media/bgm/silence-of-daylight.ogg")
		#~ @song.volume = 0.3
		#~ @song.play(true)
		#~ p "same" if $window.map.current_level == $window.level - 1
		#~ if ($window.map.current_level ==  $window.level - 1) && $window.map.current_block == 0
		#~ if $window.map.current_block == 0
			#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.map.current_level]}.ogg", :volume => 0.3)
			#~ $game_bgm.play(true)
		#~ end
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ p "#{Module_Game::BGM[$window.map.current_level]}.ogg"
		#~ p "#{Module_Game::BGM}"
		@hud.update
	end
	
	def draw
		#~ @backdrop.draw
		@hud.draw unless @hud == nil
		# Draw the static tilemap all at once and ONLY once.
		@recorded_tilemap ||= $window.record 1, 1 do
			@tiles.each &:draw
		end
		@recorded_tilemap.draw 0, 0, 0

		super
	end
	
	def edit
		#~ push_game_state(GameStates::Edit.new(:grid => [8,8], :classes => [Zombie, GroundTiled, GroundLower, GroundLoop, GroundBack, BridgeGrayDeco, BridgeGrayDecoL, BridgeGrayDecoR, BridgeGrayDecoM, BridgeGraySmall, BridgeGrayLeftSmall, BridgeGrayRightSmall, BridgeGrayPoleSmall, BridgeGrayMidSmall, Zombie, Ball_Rang, Ball,Ground] ))
		push_game_state(GameStates::Edit.new(:grid => [8,8], :classes => [Ground, GroundTiled, GroundLower, GroundLoop, GroundBack, BridgeGray, BridgeGrayLeft, BridgeGrayMid, BridgeGrayRight, BridgeGrayPole, BridgeGrayLL, BridgeGrayLR, BridgeGrayDeco, BridgeGrayDecoL, BridgeGrayDecoR, BridgeGrayDecoM] ))
	end
	
	def clear_game_terrains
		@tiles.each {|me| me.destroy}
		$window.hazards.each {|me|me.destroy_all}
		$window.items.each {|me|me.destroy}
	end
	
	def clear_subweapon_projectile
		Sword.destroy_all
		$window.subweapons.each {|me|me.destroy_all}
	end
	
	def restart
		clear_subweapon_projectile
		clear_game_terrains
		$window.reset_stage
	end
	
	def pause
		$window.transfer
		$window.paused = true
		$window.frame_last_tick = $window.frame
		game_objects.each { |game_object| game_object.pause }
		#~ push_game_state(Pause)
		push_game_state(Pause)
	end
	
	def player_start
		@player = Player.create()
		@player.reset_state
	end
	
	def to_next_block
		#~ $window.wait(10)
		clear_game_terrains
		@player.status = :blink
		@player.sword.die if @player.sword != nil
		$window.transfer
		#~ $window.block += 1
		switch_game_state($window.map.next_block)
		$window.block += 1
		#~ after(100) { $window.stop_transferring }
	end
	
	def to_next_level
		@player.status = :blink
		@player.sword.die if @player.sword != nil
		clear_game_terrains
		$window.transfer
		#~ $window.block += 1
		switch_game_state($window.map.next_level)
		$window.level += 1
		$window.block  = 1
		#~ after(100) { $window.stop_transferring }
	end
	
	def update
		game_objects.each { |game_object| game_object.unpause } if !$window.paused and !$window.transferring
		super
		#~ update_trait unless $window.paused
		@hud.update
		#~ update_trait
		self.viewport.center_around(@player) unless $window.passing_door
		#~ game_objects.each { |game_object| game_object.unpause } # if !$window.paused
		Knife.destroy_if {|knife| 
			knife.x > self.viewport.x + $window.width/2 + $window.width/16 or 
			knife.x < self.viewport.x - $window.width/16 or 
			self.viewport.outside_game_area?(knife)
		}
		Axe.destroy_if {|axe| axe.y > self.viewport.y + $window.height/2 or axe.x < self.viewport.x or axe.x > self.viewport.x + $window.width/2}
		Rang.destroy_if {|rang| self.viewport.outside_game_area?(rang) and rang.turn_back }
		Axe_Rang.destroy_if {|axerang| self.viewport.outside_game_area?(axerang) and axerang.turn_back }
		if @player.y > self.viewport.y + $window.height/2 + (2*@player.height)
			@player.dead 
		end
		#~ $window.caption = "Scene0, FPS: #{$window.fps}, #{@player.x.to_i}:#{@player.y.to_i}[#{@player.velocity_y.to_i}-#{@player.y_flag}], #{$window.subweapon}"
		#~ $window.caption = "Scene0, #{@player.status}, #{@player.action}"
		$window.caption = "Scene0, FPS: #{$window.fps} | #{$window.frame}, [#{@player.status}, #{@player.action}]"
	end
end

class Level00 < Scene
	def initialize
		super
		@area = [512, 304]
		self.viewport.game_area = [0,0,@area[0],@area[1]]
		self.viewport.y = 64
		@player.x = 64
		@player.y = 272
		@player.y_flag = @player.y
		@backdrop << {:image => "parallax/panorama1-1.png", :damping => 10, :repeat_x => true, :repeat_y => false}
		@backdrop << {:image => "parallax/bg1-1.png", :damping => 5, :repeat_x => true, :repeat_y => false}
		update
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ $game_bgm.play(true)
	end
	
	def draw
		@backdrop.draw
		super
	end
	 
	def update
		super
		if @player.x >= @area[0]-(@player.bb.width) - 4 and @player.idle # and !$window.waiting
			$window.in_event = true
			@player.move(2,0)
			if @player.x >= @area[0] + 32
				to_next_block; $window.in_event = false
			end
		end
		
		#~ if @player.x >= 240 and @player.idle and !@in_other_room
			#~ $window.in_event = true
			#~ $window.passing_door = true
			#~ if self.viewport.x < 160
				#~ self.viewport.x += 4
			#~ else
				#~ if @player.x < 368
					#~ @player.move(2,0)
				#~ end
				#~ if @player.x >= 368
					#~ @in_other_room = true
					#~ $window.in_event = false
					#~ $window.passing_door = false
				#~ end
			#~ end
		#~ end
		
		@backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i 
		@backdrop.update
	end
end

class Level01 < Scene
	def initialize
		super
		@area = [640,304]
		@player.x = 16 # self.viewport.x+(@player.bb.width/2)+16 # 32
		@player.y = 272 # 246
		@player.y_flag = @player.y
		self.viewport.game_area = [0,0,@area[0],@area[1]]
		self.viewport.y = 80
		@backdrop << {:image => "parallax/panorama1-1.png", :damping => 10, :repeat_x => true, :repeat_y => false}
		@backdrop << {:image => "parallax/bg1-1.png", :damping => 5, :repeat_x => true, :repeat_y => false}
		update
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ $game_bgm.play(true)
	end
	
	def draw
		@backdrop.draw
		super
	end
	 
	def update
		super
		#~ if @player.x >= @area[0]-(@player.bb.width) && (@player.y > 214 && @player.y < 216) # self.viewport.x+$window.width-(@player.bb.width/2)-1
			#~ to_next_block
		#~ end
		@backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		@backdrop.update
	end
end

#~ class Level10 < Scene
	#~ def initialize
		#~ super
		#~ every(2000){@text = Text.create(:name => :woof, :text => "Woof!", :x=>@player.x, :y=>100, :size=>10, :zorder => 400)}
		#~ @area = [592,288]
		#~ @player.x = 32
		#~ @player.y = 246
		#~ @player.y_flag = @player.y
		#~ self.viewport.game_area = [0,0,@area[0],@area[1]]
		#~ @backdrop << {:image => "parallax/panorama1-1.png", :damping => 10, :repeat_x => true, :repeat_y => false}
		#~ @backdrop << {:image => "parallax/bg1-1.png", :damping => 1, :repeat_x => true, :repeat_y => false}
	
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ $game_bgm.play(true)
		#~ @song = Gosu::Song.new("media/bgm/silence-of-daylight.ogg")
		#~ @song.volume = 0.3
		#~ @song.play(true)
	#~ end
	
	#~ def draw
		#~ @backdrop.draw
		#~ fill_gradient(:from => Color.new(0xff444AFF), :to => Color.new(0xff444AFF), :zorder => -1)
		#~ super
	#~ end
	 
	#~ def update
		#~ super
		#~ if @player.x >= @area[0]-(@player.bb.width) && (@player.y > 214 && @player.y < 216) # self.viewport.x+$window.width-(@player.bb.width/2)-1
			#~ to_next_block
		#~ end
		#~ @backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		#~ @backdrop.update
	#~ end
#~ end