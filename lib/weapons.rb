# ------------------------------------------------------
# Weapons
# When you need self-defense
# ------------------------------------------------------
class Sword < GameObject
	#~ trait :bounding_box, :scale => [1, 0.25], :debug => false
	trait :bounding_box, :debug => false
	traits :collision_detection, :timer, :velocity
	attr_reader :damage
	attr_accessor :zorder
	
	def initialize(options={})
		super
		@player = parent.player
		@image = Image["weapons/sword-#{$window.wp_level}.gif"]
		self.rotation_center = :center_left
		@zorder = @player.zorder
		@velocity_x *= 1
		@velocity_y *= -1 if self.velocity_y > 0
		@velocity_y *= 1
		@collidable = false
		@damage = $window.wp_level*2
		@damage = 4 if $window.wp_level >= 3
		cache_bounding_box
	end
	
	def die
		self.destroy
	end
end

# ------------------------------------------------------
# Le Projectile
# When you might need something to throw...
# ------------------------------------------------------
class Subweapons < GameObject
	trait :bounding_box, :scale => [1, 1],:debug => false
	traits :collision_detection, :timer, :velocity
	attr_accessor :damage
	
	def self.descendants
		ObjectSpace.each_object(Class).select { |klass| klass < self }
	end
	
	def setup
		@player = parent.player
	end
	
	def die
		destroy
	end
end

class Knife < Subweapons
	attr_accessor :damage
	
	def setup
		super
		@image = Image["weapons/knife.gif"]
		@zorder = 300
		@velocity_x *= 6
		@velocity_y *= 1
		@max_velocity = 8
		@rotation = 0
		@damage = 2
		cache_bounding_box
	end
	
	def deflect
		Sound["sfx/klang.wav"].play(0.1)
		@velocity_x *= -0.15
		@velocity_y = -6
		#~ @velocity_y = -9
		@rotation = 25*@velocity_x
		@acceleration_y = Module_Game::Environment::GRAV_ACC # 0.5
		@collidable = false
	end
	
	def update
		@angle += @rotation
		self.each_collision(*$window.terrains) do |knife, wall|
			knife.deflect
		end
	end
	
	def die
		self.collidable = false
		@velocity_x = 0
		#~ after(100){super}
		after(3){super}
	end
end

class Axe < Subweapons
	attr_accessor :damage
	
	def setup
		super
		@image = Image["weapons/ax.gif"]
		@zorder = 300
		@velocity_x *= 2
		@velocity_y -= 7
		@max_velocity = Module_Game::Environment::GRAV_CAP
		#~ @acceleration_x = -0.15 # 0.4
		@acceleration_y = Module_Game::Environment::GRAV_ACC # 0.4
		@rotation = 15*@velocity_x
		@damage = 5
		cache_bounding_box
	end
	
	def update
		@angle += @rotation
	end
	
	def deflect
		Sound["sfx/klang.wav"].play(0.1)
		@velocity_x *= -0.2
		@velocity_y = -5
		@rotation = 10*@velocity_x
		@acceleration_y = 0.5
		@collidable = false
	end
	
	def die;super;end
end

class Axe_Rang < Subweapons
	attr_accessor :turn_back, :damage
	def setup
		super
		@image = Image["weapons/ax.gif"]
		@zorder = 300
		@velocity_x *= 2
		@velocity_y = 0
		@rotation = 15*@velocity_x
		@max_velocity = 1
		@damage = 4
		cache_bounding_box
	end
	
	def update
		between(1,1500){@velocity_x -= 0.007*self.factor_x}
		after(1500) {@turn_back = true}
		@angle += @rotation
	end
	def die;super;end
end

class Torch < Subweapons
	attr_accessor :damage, :on_ground
	
	def setup
		super
		@image = Image["weapons/torch.gif"]
		@zorder = 300
		@velocity_x *= 4
		@velocity_y = 0
		@acceleration_y = 0.4
		@max_velocity = 8
		@rotation = 50*self.factor_x
		@damage = 2
		@on_ground = false
		#~ self.rotation_center = :center_bottom
		every(6){Torch_Fire.create(:x => @x, :y => @y) if @on_ground }
		cache_bounding_box
	end
	
	def lit_fire
		@velocity_x = 0
		@velocity_y = 0
		@color.alpha = 0
		Sound["sfx/torch_fire.wav"].play unless @on_ground
		#~ Torch_Fire.create(:x => @x, :y => @y+10) if !@on_ground
		#~ after(70){@on_ground = true; Torch_Fire.create(:x => @x, :y => @y) if @on_ground}
		@on_ground = true # Torch_Fire.create(:x => @x, :y => @y)
		#~ after(500){die}
		#~ after(150){die}
		after(60){die}
	end
	
	def update
		@angle += @rotation
		self.each_collision(*$window.terrains, *$window.bridges) do |me, wall|
			if collision_at?(me.x, me.y)
				lit_fire if !@on_ground
				if self.velocity_y < 0  # Hitting the ceiling
					me.y = wall.bb.bottom + me.image.height * me.factor_y
					me.velocity_y = 0
				else  
					me.velocity_y = Module_Game::Environment::GRAV_WHEN_LAND
					me.y = wall.bb.top - 1 unless me.y > wall.y
				end
				@x = previous_x if (wall.x < me.x or wall.x > me.x) and wall.y < me.y
			end
			if @on_ground; @velocity_x = self.factor_x; @acceleration_y = 0.5; end
		end
		#~ if @on_ground; @velocity_x = self.factor_x; @acceleration_y = 0.5; end # and !self.collides?(*$window.terrains)
	end
	
	def die;super;end
end

class Torch_Fire < Subweapons
	traits :timer
	attr_accessor :damage
	
	def setup
		super
		@fire = Chingu::Animation.new( :file => "misc/fire-torch.gif", :size => [16,20])
		@fire.delay = 30
		#~ self.mode = :additive
		#~ self.factor = 2
		self.zorder = 500
		@image = @fire.first
		@damage = 2
		self.rotation_center = :bottom_center
	end
	
	def update
		@image = @fire.next
		#~ after(20){@image = @spark.next}
		#~ after(40){@image = @spark.last}
		#~ after(150){die}
		#~ after(24){die}
		after(36){die}
	end
end

class Rang < Subweapons
	attr_accessor :turn_back, :damage
	def setup
		super
		@image = Image["weapons/rang.gif"]
		@zorder = 300
		@velocity_x *= 2
		@velocity_y = 0
		@rotation = 15*@velocity_x
		@max_velocity = 2
		@damage = 3
		cache_bounding_box
		every(12){Sound["sfx/swing.wav"].play(0.5)}
	end
	
	def update
		# between(1,2000){@velocity_x -= 0.01*self.factor_x;}
		# after(2000) {@turn_back = true}
		#~ after(100) {@velocity_y = -0.25}
		after(15) {@velocity_y = -0.25}
		#~ after(750) {@velocity_y = 0.25}
		after(45) {@velocity_y = 0.25}
		#~ between(1,1500){@velocity_x -= 0.003*self.factor_x}
		between(1, 75){@velocity_x -= 0.003*self.factor_x}
		#~ after(1500) {@turn_back = true}
		after(75) {@turn_back = true}
		@angle += @rotation
	end
	def die;super;end
end