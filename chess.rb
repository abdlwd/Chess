require "./board"
# encoding: utf-8


class Chess
  def initialize
    @board = Board.new
    @turn = :white
  end 
  
  def run 
    until @board.over?
      play_one_turn
      toggle_turn
    end 
    @board.display
    
    if @board.checkmate?(:white)
      p "Black wins"
    elsif @board.checkmate?(:black)
      p "White wins"
    elsif @board.stalemate?
      p "It's a draw"
    end 
    
  end 
  
  private 
  
  def coord_to_pos(letter, number)
    letters_hash = Hash[("a".."h").to_a.zip((1..8).to_a)]
    x = letters_hash[letter]
    y = 9 - number
    
    [x, y]
  end 
  
  def parse_input(input)
    parts = input.delete(" ").split(",")
  
    parts.map do |command|
      coord_to_pos(command[0].downcase, command[1].to_i)
    end 
  end 
  
  def play_one_turn
    @board.display
    
    begin 
      puts "#{@turn}'s turn."
      puts "Select a start and end coordinate, separated by a comma (ex. 'a2, a3')"
      input = gets.chomp
      from_pos, to_pos = parse_input(input)
      piece = @board.get_piece(from_pos)
    
      error_handling(from_pos, to_pos)

      @board.move(from_pos, to_pos)
    rescue BadMoveError => e
      @board.display
      puts e
      retry
    end 
    
    @board.clean_phantoms
  end 
  
  def error_handling(from_pos, to_pos)
    piece = @board.get_piece(from_pos)
    
    if piece.nil?
      raise BadMoveError.new("Start position is empty") 
    elsif from_pos == to_pos
      raise BadMoveError.new("Start and end can't be equal") 
    elsif piece.color != @turn
      raise BadMoveError.new("Cannot move a piece that isn't yours")
    end 
  end 
  
  def toggle_turn
    @turn = @turn == :black ? :white : :black
  end 
end 


if __FILE__ == $PROGRAM_NAME
  chess = Chess.new
  chess.run
  
  
  
end 