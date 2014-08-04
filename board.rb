require "./piece"
class Board
  
  attr_reader :position_hash

  public 

  def initialize(start = true)
    @position_hash = {}
    @phantoms = []
    if start
      (1..8).each do |x|
        (1..8).each do |y|
          pos = [x, y]
          @position_hash[pos] = starting_piece(pos)
        end 
      end 
    end 
    
  end 
  
  def get_piece(pos)
    @position_hash[pos]
  end 
  
  def dup
    dup_board = Board.new(false)
    (1..8).each do |x|
      (1..8).each do |y|
        pos = [x, y]
        piece = get_piece(pos)
        next if piece.nil?
        dup_piece = piece.class.new(pos, dup_board, piece.color)
        dup_board.position_hash[pos] = dup_piece
      end 
    end 
    return dup_board
  end 
  
  def remove_piece(pos)
    @position_hash[pos] = nil
  end 
  
  def in_check?(color)
    king = find_king(color)
    king_pos = king.pos
    opponent_color = Board.other_color(color) 
    
    get_all_pieces(opponent_color).any? do |piece|
      (piece.include_move?(king_pos))
    end 
  end 
  
  def over?
    won? || stalemate?
  end 
  
  def move(start_pos, end_pos)
    piece = get_piece(start_pos)

    
   
    valid_moves = piece.valid_moves
    if valid_moves.include?(end_pos)
      if piece.is_a?(Pawn) 
        en_passant(start_pos, end_pos) 
      end 
      move!(start_pos, end_pos)
    else 
      raise BadMoveError.new("That move is not valid")
    end 
  end  
  
  def move!(start_pos, end_pos)
    piece = get_piece(start_pos)
    
    @position_hash[end_pos] = piece
    piece.pos = end_pos
    @position_hash[start_pos] = nil
  end  
  
  def en_passant(start_pos, end_pos)
    piece = get_piece(start_pos)
    end_piece = get_piece(end_pos)
    
    if (end_pos[1] - start_pos[1]).abs == 2 # If a pawn moved two steps
      x = end_pos[0]
      y = piece.color == :white ? end_pos[1] + 1 : end_pos[1] - 1 
      phantom_pawn = PhantomPawn.new([x, y], piece)
      @phantoms << phantom_pawn
      @position_hash[[x, y]] = phantom_pawn
    
    elsif end_piece.is_a?(PhantomPawn) # If a pawn is moving to a PhantomPawn
      phantom = end_piece
      remove_piece(phantom.pawn.pos)
      delete_phantom(phantom)
    end   
  end
  
  
  
  def self.other_color(color)
    color == :black ? :white : :black
  end 
  
  def display
    puts 
    puts "    A B C D E F G H" 
    printing = ""
    (1..8).each do |y|
      printing << "#{9 - y}|  "
     (1..8).each do |x|
        pos = [x, y]
        piece = get_piece(pos)
        if piece.nil?
          printing << "_ "
        else            
          printing << piece.to_s
        end 
      end  
      printing << "\n"
    end
  
    puts printing 
    puts 
  end 
  
  def self.in_bounds?(pos)
    x, y = pos
    (1..8).include?(x) && (1..8).include?(y)
  end 
  
  
  def delete_phantom(phantom)
    @phantoms.delete(phantom)
    remove_piece(phantom.pos)
  end 
  
  def clean_phantoms
    phantoms_copy = []
    @phantoms.each_with_index do |phantom, index|
      if phantom.alive
        phantom.alive = false
        phantoms_copy << phantom
      else 
        remove_piece(phantom.pos)
      end 
    end 
    @phantoms = phantoms_copy
  end 
  
  private
  
  def get_all_pieces(color)
    @position_hash.values.select { |piece| !piece.nil? && piece.color == color }
  end 
    
  
  def get_every_piece
    get_all_pieces(:black) + get_all_pieces(:white)
  end 
  
  # Handles initial setup of board
  def starting_piece(pos)
    x, y = pos
    
    case y
    when 1
      color = :black
    when 2
      color = :black
      return Pawn.new(pos, self, color)
    when 7
      color = :white
      return Pawn.new(pos, self, color)
    when 8
      color = :white
    else 
      return nil
    end 
    
    case x
    when 1,8
       return Rook.new(pos, self, color)
    when 2, 7
      return Knight.new(pos, self, color)
    when 3, 6
      return Bishop.new(pos, self, color)
    when 4
      return Queen.new(pos, self, color)
    when 5
      return King.new(pos, self, color)
    end 
  end 
  
  def find_king(color)
    all_pieces = get_all_pieces(color)
    king = all_pieces.find do |piece|
      piece.is_a?(King) && piece.color == color
    end 
    king
  end 
  
  def checkmate?(color)
    no_valid_moves = get_all_pieces(color).all? do |piece|
      piece.valid_moves.empty?
    end 
    
    in_check?(color) && no_valid_moves
  end 
  
  def stalemate?
    no_valid_moves = get_every_piece.all? do |piece|
      piece.valid_moves.empty? 
    end 
    
    !in_check?(:white) && !in_check?(:black) && no_valid_moves
  end 
  
  def won? 
    checkmate?(:black) || checkmate?(:white)
  end 
        
end 

class BadMoveError < StandardError
end 

