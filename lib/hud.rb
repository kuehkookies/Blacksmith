# ------------------------------------------------------
# Heads-up-display
# ------------------------------------------------------
class HUD < Chingu::BasicGameObject
	attr_reader :gap
	def initialize(options={})
		super
		@player = options[:player] || parent.player
		@x = options[:x]; @y = options[:y]
		#~ @old_hp = @player.hp
		@old_hp = $window.hp
		@hud = Image["misc/hud.gif"]
		if $window.subweapon == :none
			@sub = nil
		else
			@sub = Image["misc/hud_#{$window.subweapon}.gif"] 
		end
		@ammo = Text.new($window.ammo, :x => 36, :y => 55, :zorder => 300, :align => :right, :max_width => 16, :size => 16, :color => Color.new(0xFFDADADA), :font => "fonts/runescape_uf_regular.ttf")
		#~ @ammo = Text.new($window.ammo, :x => 36, :y => 55, :zorder => 300, :align => :right, :max_width => 16, :size => 16, :color => Color.new(0xFFDADADA))
		@rect = Rect.new(45,23,168*$window.hp/$window.maxhp,10)
		@gap = (@rect.width - 168*$window.hp/$window.maxhp).to_f
	end
	
	def draw
		@hud.draw(15,15,300)
		@sub.draw(21,24,301) unless @sub == nil
		# @bar.draw
		# @life.draw
		@ammo.draw
		# @sub.draw
		# parent.fill_rect(Rect.new(45,23,168,10), Color.new(128,40,40,40), 150)
		# @rect = Rect.new(45,23,168*@player.hp/@player.maxhp,10)
		parent.fill_gradient(:from => Color.new(255,20,20), :to => Color.new(160,20,20), :rect => @rect, :orientation => :vertical, :zorder => 290 )
	end
	
	def refill_to_full
		@rect.width = 168
	end
	
	def update
		# @life.text = @player.hp.to_s unless @player.hp.to_s == @life.text
		# @sub.text = @player.subweapon.to_s unless @player.subweapon.to_s == @sub.text
		@sub = Image["misc/hud_#{$window.subweapon}.gif"] unless $window.subweapon == @sub or $window.subweapon == :none
		@ammo.text = $window.ammo.to_s unless $window.ammo.to_s == @ammo.text
		if $window.hp < @old_hp
			unless @rect.width <= 168*$window.hp/$window.maxhp
				#~ @rect.width -= 4 if @gap > 4
				#~ @rect.width -= 2 if @gap <= 4 and @gap > 2
				@rect.width -= 1 # if @gap <= 2
			end
		else
			unless @rect.width >= 168*$window.hp/$window.maxhp
				#~ @rect.width += 4 if @gap < -4
				#~ @rect.width += 2 if @gap >= -4 and @gap < -2
				@rect.width += 1 # if @gap >= -2hp
			end
		end
		#~ @rect.width = 168*$window.hp/$window.maxhp unless $window.hp == @old_hp
	end
end