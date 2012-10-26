require 'rubygems' rescue nil
require 'bundler/setup'
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require 'texplay'
include Chingu
include Gosu

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

#~ $game_bgm = nil

#~ $game_enemies = []
#~ $game_hazards = []
#~ $game_terrains = []
#~ $game_bridges = []
#~ $game_misc_tiles = []
#~ $game_tiles = []
#~ $game_items = []
#~ $game_subweapons = []

# ------------------------------------------------------
# Main process
# Everything started here.
# ------------------------------------------------------
class Game < Chingu::Window
	attr_accessor :level, :block, :lives, :hp, :maxhp, :ammo, :wp_level, :subweapon, :map, :transfer
	attr_accessor :bgm, :enemies, :hazards, :terrains, :bridges, :decorations, :tiles, :items, :subweapons
	attr_accessor :paused, :waiting, :in_event
	
	def initialize
		#~ super(544,416)
		super(640,480)
		
		Sound["sfx/swing.wav"]
		Sound["sfx/klang.wav"]
		Sound["sfx/hit.wav"]
		Sound["sfx/grunt.ogg"]
		Sound["sfx/step.wav"]
		Sound["sfx/rifle.ogg"]
		
		Font["runescape_uf_regular.ttf", 16]
		
		@bgm = nil
		@enemies = []
		@terrains = []
		@bridges = []
		@decorations = []
		@tiles = []
		@items = []
		@subweapons = []
		@paused = false
		@waiting = false
		@in_event = false
		
		retrofy # THE classy command!
		setup_player
		setup_stage
		set_terrains
		set_enemies
		set_subweapons
		#~ self.factor = 2
		@transfer = true
		transitional_game_state(Transitional, :speed => 32)
		blocks = [
			[Level00, Level01]
		]
		@bgm = Module_Game::BGM[@level]
		#~ p $Game_BGM
		@map = Map.new(:map =>blocks, :row => @level-1, :col => @block-1)
		switch_game_state(@map.current)
		#~ switch_game_state(Level00)
		#~ transitional_game_state(Transitional, :speed => 32)
		self.caption = "Scene0"
	end
	
	def setup_stage
		@level = 1
		@block = 1
	end
	
	def reset_stage
		transferring
		setup_player
		switch_game_state($window.map.first_block)
		@block = 1
	end
	
	def transferring
		@transfer = true
	end
	
	def stop_transferring
		@transfer = false
	end
	
	def setup_player
		@hp = @maxhp = 16
		#~ @lives = 3 unless @lives > 0
		@ammo = 10
		@wp_level = 1
		@subweapon = :none
	end
	
	def set_terrains
		@terrains = Solid.descendants
		@decorations = Decoration.descendants
	end
	
	def set_enemies
		@enemies = Enemy.descendants
	end
	
	def set_subweapons
		@subweapons = Subweapons.descendants
		#~ @subweapons = [Knife, Axe, Rang]
	end
	
	def clear_cache
		#~ $game_bgm = nil
		@enemies = []
		@hazards = []
		#~ $game_terrains = []
		@bridges = []
		@tiles = []
		@items = []
		#~ @subweapons.each {|me|me.destroy} if @subweapons != []
		#~ @subweapons = []
	end
	
	def wait(duration)
		@waiting = true
		for i in 0..duration
			update
			@waiting = false if i >= duration
		end
	end
	
	def draw
		scale(2) do
		   super
		end
	end
end

# This is important.
Game.new.show
