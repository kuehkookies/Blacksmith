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
		#~ @collidable = false
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
		after(100){super}
	end
end

class Axe < Subweapons
	attr_accessor :damage
	
	def setup
		super
		@image = Image["weapons/ax.gif"]
		@zorder = 300
		@velocity_x *= 2
		@velocity_y = -7
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
	end
	
	def update
		# between(1,2000){@velocity_x -= 0.01*self.factor_x;}
		# after(2000) {@turn_back = true}
		after(100) {@velocity_y = -0.25}
		after(750) {@velocity_y = 0.25}
		between(1,1500){@velocity_x -= 0.003*self.factor_x}
		after(1500) {@turn_back = true}
		@angle += @rotation
	end
	def die;super;end
end