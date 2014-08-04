require "./board"
# encoding: utf-8


class Piece 
  
  attr_accessor :pos
  attr_reader :board, :color
  
  DELTAS = {
    :up => [0, -1],
    :down => [0, 1],
    :left => [-1, 0],
    :right => [1, 0],
    :upleft => [-1, -1],
    :upright => [1, -1],
    :downleft => [-1, 1],
    :downright => [1, 1]
  }
  
  public 
  
  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end 
  
  
  def include_move?(pos)
    moves.include?(pos)
  end 
  
  def valid_moves
    moves.reject{ |move| move_into_check?(move) }
  end 
  
  def same_color?(other_piece)
    @color == other_piece.color
  end 
  
  private 
  
  def move_into_check?(new_pos)
    dup_board = @board.dup
    dup_board.move!(@pos, new_pos)
    dup_board.in_check?(@color)
  end 


end 

class SlidingPiece < Piece
  
  public 
  
  def moves
    moves_array = []
    move_dirs.each do |dir|
      moves_array.concat(search_direction(dir))
    end 
    
    moves_array
  end 
  
  private 
  
  def search_direction(direction)
    # Returns array of available positions in a given direction
    
    output = []
    x, y = @pos
    dx, dy = DELTAS[direction]
    new_pos = [x + dx, y + dy] 
    new_piece = @board.get_piece(new_pos) 
    while new_piece.nil? && Board.in_bounds?(new_pos) 
      output << new_pos
      x, y = new_pos
      new_pos = [x + dx, y + dy]
      new_piece = @board.get_piece(new_pos)
    end 
    if Board.in_bounds?(new_pos)
      if new_piece.color != @color
        output << new_pos
      end 
    end 
    output
  end 
  

end 

class SteppingPiece < Piece
  
  def moves
    x, y = @pos
    valid_deltas = move_deltas.select do |delta|
      dx, dy = delta
      new_pos = [x + dx, y + dy]
      if !Board.in_bounds?(new_pos)
        false
      else 
        new_piece = @board.get_piece(new_pos) 
        if new_piece.nil? || !self.same_color?(new_piece) 
          true
        else 
          false
        end  
      end 
    end 
    valid_deltas.map do |dx, dy|
      [x + dx, y + dy]
    end 
  end 
 
end 

class Bishop < SlidingPiece
  
  public 
  
  def to_s
    u = @color == :black ? "\u265D" : "\u2657" 
    u.encode('utf-8') + " "
  end 
  
  private 
  
  def move_dirs
    [:upleft, :downleft, :upright, :downright]
  end 
    
end 

class Rook < SlidingPiece
  
  public 
  
  def to_s
    u = @color == :black ? "\u265C" : "\u2656" 
    u.encode('utf-8') + " "
  end 
  
  private 
  
  def move_dirs
    [:left, :up, :down, :right]
  end 
  
end 

class Queen < SlidingPiece

  public 
  
  def to_s
    u = @color == :black ? "\u265B" : "\u2655" 
    u.encode('utf-8') + " "    
  end 
  
  private 
  
  def move_dirs
    [:left, :up, :down, :right, :upleft, :downleft, :upright, :downright]
  end 
  
end 

class Knight < SteppingPiece
  
  public 
  
  def to_s
    u = @color == :black ? "\u265E" : "\u2658" 
    u.encode('utf-8') + " "    
  end 
  
  private 
  
  def move_deltas 
    [[-1, -2], [1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1]]
  end 
end 

class King < SteppingPiece
  
  public 
  
  def to_s
    u = @color == :black ? "\u265A" : "\u2654" 
    u.encode('utf-8') + " "
  end 
  
  private 
  
  def move_deltas
    DELTAS.values
  end
end 

class Pawn < Piece
  
  public 
  
  def initialize(pos, board, color)
    super 
    @first_move = true
  end 
  
  def pos=(new_pos)
    @pos = new_pos
    @first_move = false
  end 
  
  def moves
        
    x, y = @pos
    moves = []
    
    delta = DELTAS[move_dir]
    dy = delta[1]
    new_move = [x, y + dy]
    new_piece = @board.get_piece(new_move)
    moves << new_move if new_piece.nil?
    
    if @first_move
      new_move = [x, y + (dy * 2)]
      new_piece = @board.get_piece(new_move)
      moves << new_move if new_piece.nil?
    end
    
    possible_enemy_positions = [ [x + 1, y + dy], [x - 1, y + dy] ]
    possible_enemy_positions.each do |pos|
      piece = @board.get_piece(pos)
      if (!piece.nil? || piece.is_a?(PhantomPawn)) && !self.same_color?(piece)
        moves << pos
      end 
    end 
    moves
  end 
  
  def to_s
    u = @color == :black ? "\u265F" : "\u2659" 
    u.encode('utf-8') + " "
  end 
  
  private 
  
  def move_dir
    @color == :black ? :down : :up
  end 
  
end 

class PhantomPawn
 
  attr_accessor :pawn, :alive, :pos, :color, :board
  
  def initialize(pos, pawn)
    @pos = pos
    @board = pawn.board
    @color = pawn.color
    @alive = true
    @pawn = pawn
  end 
  
  def nil?
    true
  end 

end  
