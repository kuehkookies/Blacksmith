# ------------------------------------------------------
# Heads-up-display
# ------------------------------------------------------
#~ class HUD < Chingu::BasicGameObject
class HUD < Chingu::GameObject
	attr_reader :gap, :rect
	def initialize(options={})
		super
		@player = options[:player] || parent.player
		@x = options[:x]; @y = options[:y]
		#~ @old_hp = @player.hp
		@old_hp = $window.maxhp
		@image = Image["misc/hud.gif"]
		get_subweapon
		#~ @ammo = Text.new($window.ammo, :x => 36, :y => 55, :zorder => 300, :align => :right, :max_width => 16, :size => 16, :color => Color.new(0xFFDADADA), :font => "fonts/runescape_uf_regular.ttf", :factor => 1)
		@ammo = Text.new($window.ammo, :x => 27, :y => 30, :zorder => 300, :align => :right, :max_width => 12, :size => 12, :color => Color.new(0xFFDADADA), :factor => 1)
		#~ @ammo = Text.new($window.ammo, :x => 36, :y => 55, :zorder => 300, :align => :right, :max_width => 16, :size => 16, :color => Color.new(0xFFDADADA))
		#~ @rect = Rect.new(15,23,168*$window.hp/$window.maxhp,10)
		@rect = Rect.new(32,16,84*$window.hp/$window.maxhp,5)
		@gap = (@rect.width - 168*$window.hp/$window.maxhp).to_f
	end
	
	def draw
		#~ @image.draw(15,15,300)
		#~ @sub.draw(21,24,301) unless @sub == nil
		@image.draw(8,8,300)
		@sub.draw(12,12,299) unless @sub == nil
		# @bar.draw
		# @life.draw
		@ammo.draw
		# @sub.draw
		# parent.fill_rect(Rect.new(45,23,168,10), Color.new(128,40,40,40), 150)
		# @rect = Rect.new(45,23,168*@player.hp/@player.maxhp,10)
		parent.fill_gradient(:from => Color.new(255,20,20), :to => Color.new(160,20,20), :rect => @rect, :orientation => :vertical, :zorder => 290 )
	end
	
	#~ def refill_to_full
		#~ @rect.width = 168
	#~ end
	
	def get_subweapon
		if $window.subweapon == :none
			@sub = nil
		else
			@sub = Image["misc/hud_#{$window.subweapon}.gif"] 
		end
	end
	
	def update
		get_subweapon
		@ammo.text = $window.ammo.to_s unless $window.ammo.to_s == @ammo.text
		unless @rect.width <= 84*$window.hp/$window.maxhp
			#~ @rect.width -= 4 if @gap > 4
			#~ @rect.width -= 2 if @gap <= 4 and @gap > 2
			@rect.width -= 1 # if @gap <= 2
		end
		unless @rect.width >= 84*$window.hp/$window.maxhp and !@resetter # 168*$window.hp/$window.maxhp
			#~ @rect.width += 4 if @gap < -4
			#~ @rect.width += 2 if @gap >= -4 and @gap < -2
			@rect.width += 1 # if @gap >= -2hp
		end
		if @resetter; @old_hp = $window.maxhp; @rect.width = 84; @resetter = false; end
	end
end