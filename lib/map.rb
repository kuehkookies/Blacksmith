# ------------------------------------------------------
# Maps
# A simple implementation of block mapping
# ------------------------------------------------------

class Map
  attr_reader :row, :col
  attr_accessor :map
  
  def initialize(options = {})
    @row = options[:row] || 0
    @col = options[:col] || 0    
    @map = options[:map] || [ [ ] ] 
  end
  
  def current
    @map[@row][@col] rescue nil
  end

  def current_level
	@row rescue nil
  end
  
  def current_block
	@col rescue nil
  end

  def first_block
	@col = 0
	@map[@row][@col] rescue nil
  end
    
  def next_block
    @col += 1
    current
  end

  def prev_block
    @col -= 1
    current
  end

  def next_level
	@col = 0
    @row += 1
    current
  end

  def prev_level
	@col = 0
    @row -= 1
    current
  end

end