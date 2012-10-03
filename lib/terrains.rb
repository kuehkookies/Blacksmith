# ------------------------------------------------------
# Terrains
# When you need place to place your foot
# Also there's decorations and bridges
# ------------------------------------------------------

class Block < GameObject
  trait :bounding_box, :scale => [1,0.9], :debug => false
  trait :collision_detection
  
  def self.solid
    all.select { |block| block.alpha == 128 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end

  def setup
    # @image = Image["block-block.png"]
    # @image = Image["block-#{self.filename}.png"].dup
    @image = Image["tiles/block-#{self.filename}.png"]
	$game_terrains << self
		
    # @color = Color.new(0xff808080)
    cache_bounding_box
  end
  def update; end
end

class Bridge < GameObject
  trait :bounding_box, :scale => [1,0.9], :debug => false
  trait :collision_detection
  
  def self.solid
    all.select { |block| block.alpha == 128 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end

  def setup
    @image = Image["tiles/block-#{self.filename}.png"]
	$game_bridges << self
		
    cache_bounding_box
  end
end

class Decoration < GameObject  
  def self.solid
    all.select { |block| block.alpha == 128 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end

  def setup
    # @image = Image["block-block.png"]
    # @image = Image["block-#{self.filename}.png"].dup
    @image = Image["tiles/block-#{self.filename}.png"]
	#~ $game_decorations << self
  end
end

class GrayBridge < Block
  def setup
    super
	@color = Color.new(0xFFC7BA8E)
  end
  def update; end
end

class GrayBridgeDeco < Decoration
  def setup
    super
	@color = Color.new(0xFFC7BA8E)
  end
  def update; end
end

class Ground < Block; end
class GroundLower < Block; end
class GroundLoop < Block; end

class GroundTiled < Block; end

class GroundBack < Decoration;  def setup; super; @color = Color.new(0xff808080); end; end

class BridgeGray < GrayBridge; end
class BridgeGrayLeft < GrayBridge; end
class BridgeGrayRight < GrayBridge; end
class BridgeGrayMid < GrayBridge; end
class BridgeGrayPole < GrayBridgeDeco; end
class BridgeGrayLL < GrayBridgeDeco; end
class BridgeGrayLR < GrayBridgeDeco; end
class BridgeGrayDeco < GrayBridgeDeco; end
class BridgeGrayDecoL < GrayBridgeDeco; end 
class BridgeGrayDecoR < GrayBridgeDeco; end 
class BridgeGrayDecoM < GrayBridgeDeco; end

class BridgeGraySmall < Bridge; end
class BridgeGrayLeftSmall < Bridge; end
class BridgeGrayRightSmall < Bridge; end
class BridgeGrayMidSmall < Bridge; end
class BridgeGrayPoleSmall < Decoration; end