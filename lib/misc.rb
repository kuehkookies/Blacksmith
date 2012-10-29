# ------------------------------------------------------
# Miscellaneous things
# TODO: separating animations and hazards
# ------------------------------------------------------
class Spark < GameObject
	traits :timer
	def setup
		@spark = Chingu::Animation.new( :file => "misc/spark.gif", :size => [15,15])
		@spark.delay = 20
		self.mode = :additive
		self.zorder = 400
		@image = @spark.first
	end
	
	def update
		@image = @spark.next
		#~ after(20){@image = @spark.next}
		#~ after(40){@image = @spark.last}
		after(70){destroy}
	end
end

class Misc_Flame < GameObject
	traits :timer
	def setup
		@fire = Chingu::Animation.new( :file => "misc/fire.gif", :size => [15,20])
		@fire.delay = 20
		#~ self.mode = :additive
		#~ self.factor = 2
		self.zorder = 500
		@image = @fire.first
	end
	
	def update
		@image = @fire.next
		#~ after(20){@image = @spark.next}
		#~ after(40){@image = @spark.last}
		after(90){destroy}
	end
end

class Shot < GameObject
	traits :timer
	def setup
		@shot = Chingu::Animation.new(:file => "misc/shot.gif", :size => [10,11])
		@shot.delay = 20
		self.zorder = 300
		@image = @shot.first
	end
	
	def update
		after(20){@image = @shot.last}
		after(40){destroy}
	end
end

# ------------------------------------------------------
# Don't stop me now!
# ------------------------------------------------------
class Hazard < GameObject
	traits :collision_detection, :timer, :velocity
	attr_reader :damage
	attr_accessor :zorder
	
	def self.descendants
		ObjectSpace.each_object(Class).select { |klass| klass < self }
	end
	
	def setup
		@player = parent.player
	end
	
	def die
		self.destroy
	end

	def update
		self.each_collision(@player) do |enemy, me|
			me.knockback(@damage) unless me.invincible # or (enemy.is_a? Enemy and enemy.hp <= 0)
		end
		#~ self.each_collision(@player) do |enemy, me|
			#~ if collision_at?(me.x, me.y)
				#~ me.knockback(@damage) unless me.invincible 
			#~ end
		#~ end
	end
end

class Ghoul_Sword < Hazard
	trait :bounding_box, :debug => false
	
	def setup
		super
		@image = Image["weapons/sword-small.png"]
		self.rotation_center = :center_left
		@velocity_x *= 1
		@velocity_y *= 1
		@max_velocity = Module_Game::Environment::GRAV_CAP
		@damage = 4
		@rotation = 0
		@color = Color.new(0xff88DD44)
		cache_bounding_box
	end
	
	def die
		@acceleration_y = Module_Game::Environment::GRAV_ACC # 0.3
		self.rotation_center = :center_center
		@velocity_x = -@factor_x
		@velocity_y = -6
		@rotation = 20*@factor_x
		@collidable = false
		after(3000){destroy}
	end
	
	def update
		super
		#~ self.bb.x = @x unless self.bb.x == @x 
		@angle += @rotation
	end
end

class Bullet_Musket < Hazard
	trait :bounding_box
	def setup
		super
		@image = Image["weapons/bullet-musket.png"]
		@damage = 3
		self.rotation_center = :left_center
		self.factor_x *= 6
		self.alpha = 192
		# @velocity_x = 30*(self.factor_x*-2)
	end
	def update
		# destroy if self.parent.viewport.outside_game_area?(self)
		super
		after(100){destroy}
	end
end

class Reaper_Scite < Hazard
	trait :bounding_circle, :debug => false
	def setup
	#~ def initialize
		super
		@image = Image["weapons/reaper-scite.png"]
		@damage = 4
		#~ @collidable = false
		self.rotation_center = :center
	end
	
	def update
		self.each_collision(@player) do |enemy, me|
			if collision_at?(me.x, me.y)
				me.knockback(@damage) unless me.invincible 
			end
		end
	end
end
