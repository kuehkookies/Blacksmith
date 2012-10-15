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

  def self.descendants
	  ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def setup
    # @image = Image["block-block.png"]
    # @image = Image["block-#{self.filename}.png"].dup
    @image = Image["tiles/block-#{self.filename}.png"]
	#~ p self.class
	#~ $game_terrains << self
	#~ $game_terrains << self.name unless $game_terrains.include?(self.name)
		
    # @color = Color.new(0xff808080)
    cache_bounding_box
  end

  def update; end
end

class Solid < Block; end
class Ground < Solid; end
class GroundLower < Solid; end
class GroundLoop < Solid; end
class GroundTiled < Solid; end

class Bridge < Block; end

class Decoration < Block; end
class GroundBack < Decoration;  def setup; super; @color = Color.new(0xff808080); end; end

#~ class GrayBridge < Bridge
  #~ def setup
    #~ super
	#~ @color = Color.new(0xFFC7BA8E)
  #~ end
#~ end

#~ class GrayBridgeDeco < Bridge # Decoration
  #~ def setup
    #~ super
	#~ @color = Color.new(0xFFC7BA8E)
  #~ end
#~ end


#~ class BridgeGray < GrayBridge; end
#~ class BridgeGrayLeft < GrayBridge; end
#~ class BridgeGrayRight < GrayBridge; end
#~ class BridgeGrayMid < GrayBridge; end
#~ class BridgeGrayPole < GrayBridgeDeco; end
#~ class BridgeGrayLL < GrayBridgeDeco; end
#~ class BridgeGrayLR < GrayBridgeDeco; end
#~ class BridgeGrayDeco < GrayBridgeDeco; end
#~ class BridgeGrayDecoL < GrayBridgeDeco; end 
#~ class BridgeGrayDecoR < GrayBridgeDeco; end 
#~ class BridgeGrayDecoM < GrayBridgeDeco; end
#~ class BridgeGraySmall < Bridge; end
#~ class BridgeGrayLeftSmall < Bridge; end
#~ class BridgeGrayRightSmall < Bridge; end
#~ class BridgeGrayMidSmall < Bridge; end
#~ class BridgeGrayPoleSmall < Decoration; end

