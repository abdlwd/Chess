Chess
=====

### Overview

This is a simple version of two-player Chess built in Ruby. It is played in the terminal. To play, run the command "ruby chess.rb". 

Choose a move by entering two coordinates: one corresponding to the position of the move, and one corresponding to the end position. For example, the command "a2, a3" will move the piece from position A2 to A3. Whitespace is ignored. The game will do error handling to ensure that the move is valid. 

### Alternate Rules

This version of Chess does not feature some alternate rules like castling or pawn promotion. It does, however, feature [En passant](http://en.wikipedia.org/wiki/En_passant)
 

## Future Todos

### AI opponent

I'd like to build a simple AI to play against. Users should have the option to play human vs human, or human vs computer, or computer vs computer. The AI would use basic heursistics, like taking a winning move if possible, preventing a losing move, if possible, or taking the highest ranking opponent piece if possible. 

### Game saving and loading

At any point, a player should be able to save the game, probably serializing it as a YAML file, and then reload the game at a later time.  
