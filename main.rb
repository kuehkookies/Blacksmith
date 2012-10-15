require 'rubygems' rescue nil
require 'bundler/setup'
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require 'texplay'
include Chingu
include Gosu

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

$game_bgm = nil

$game_enemies = []
$game_hazards = []
$game_terrains = []
$game_bridges = []
$game_misc_tiles = []
$game_tiles = []
$game_items = []
$game_subweapons = []

# ------------------------------------------------------
# Main process
# Everything started here.
# ------------------------------------------------------
class Game < Chingu::Window
	attr_accessor :level, :block, :lives, :hp, :maxhp, :ammo, :wp_level, :subweapon, :map, :transfer
	
	def initialize
		#~ super(384,288)
		#~ super(416,288)
		#~ super(592,288)
		#~ super(640,288)
		#~ super(800,600)
		super(544,416)
		
		Sound["sfx/swing.wav"]
		Sound["sfx/klang.wav"]
		Sound["sfx/hit.wav"]
		Sound["sfx/grunt.ogg"]
		Sound["sfx/step.wav"]
		Sound["sfx/rifle.ogg"]
		
		Font["runescape_uf_regular.ttf", 16]
		
		retrofy # THE classy command!
		#~ Gosu.enable_undocumented_retrofication
		setup_player
		setup_stage
		set_terrains
		#~ self.factor = 2
		@transfer = true
		transitional_game_state(Transitional, :speed => 32)
		blocks = [
			[Level00, Level01]
		]
		$Game_BGM = Module_Game::BGM[@level]
		#~ p $Game_BGM
		@map = Map.new(:map =>blocks, :row => @level-1, :col => @block-1)
		switch_game_state(@map.current)
		#~ switch_game_state(Level00)
		#~ transitional_game_state(Transitional, :speed => 32)
		# self.caption = "Le Trial"
	end
	
	def setup_stage
		@level = 1
		@block = 1
	end
	
	def reset_stage
		transferring
		switch_game_state($window.map.first_block)
		setup_player
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
		$game_terrains = Solid.descendants
	end
	
	def clear_cache
		#~ $game_bgm = nil
		$game_enemies = []
		$game_hazards = []
		#~ $game_terrains = []
		$game_bridges = []
		$game_tiles = []
		$game_items = []
		$game_subweapons.each {|me|me.destroy} if $game_subweapons != []
		$game_subweapons = []
	end
	
	def draw
		scale(2) do
		   super
		end
	end
end

# This is important.
Game.new.show
