require 'pry'
module GetFileContents
	def get_contents(filename)
		file = File.open(filename,"r")
		input = file.read.split(/\n/)
		file.close
		input
	end
end

module Movements
	def is_horizontal(origin,destination)
		origin[0] == destination[0] ? true : false
	end

	def is_vertical(origin,destination)
		origin[1] == destination[1] ? true : false
	end

	def is_diagonal(origin,destination)

		diffO = origin.max - origin.min
		diffD = destination.max - destination.min

		diffX = (origin[0] - destination[0]).abs
		diffY = (origin[1] - destination[1]).abs

		diffX == diffY ? true : false

	end

	def is_one_step(origin,destination)
		if is_vertical(origin,destination) 
			(destination[0]-origin[0]).abs == 1 ? true : false
		elsif is_horizontal(origin,destination)
			(destination[1]-origin[1]).abs == 1 ? true : false
		else #is_diagonal(origin,destination)
			(destination[0]-origin[0]).abs && (destination[1]-origin[1]).abs == 1 ? true : false

		end

	end
	
	def is_two_steps(origin,destination)
		(destination[0]-origin[0]).abs == 2 || (destination[1]-origin[1]).abs == 2 ? true : false
	end

	def is_forward(origin,destination)
		if @color == "w"
			destination[0] > origin[0] ? true : false
		elsif @color == "b"
			destination[0] < origin[0] ? true : false
		end
	end
	
	def is_L(origin,destination)
		!is_vertical(origin,destination) && !is_horizontal(origin,destination) && !is_diagonal(origin,destination) && is_two_steps(origin,destination)		
	end
end

class Moves
	attr_reader :moves
	include GetFileContents

	def initialize(movefile)
		@moves = get_contents(movefile)
	end
end

class Board
	include GetFileContents
	attr_reader :board

	def initialize(boardfile)
		@board = set_board(boardfile)
		@pieces = { bP: Pawn, bR: Rook, bN: Knight, bB: Bishop, bQ: Queen, bK: King,
					wP: Pawn, wR: Rook, wN: Knight, wB: Bishop, wQ: Queen, wK: King
				}
		@positions = set_positions
		#binding.pry
	end

	def set_positions
		letters = "abcdefgh"
		numbers = "12345678"
		positions = []
		x_coords = "01234567"
		y_coords = "01234567"
		xy_coords = []

		posHash = { }

		numbers.split(//).each { |n| letters.split(//).each { |l| positions.push((l + n).to_sym) } }

		x_coords.split(//).each { |x| y_coords.split(//).each { |y| xy_coords.push([x.to_i , y.to_i]) } }

		positions.each_with_index {|p,i| posHash[p] = xy_coords[i] }
		posHash
	end

	def set_board(boardfile)
		input = get_contents(boardfile)
		input.map! { |i| i.split(" ") }

		input.each do |i|
			i.map! { |j| j.to_sym }
		end

		input.reverse
	end

	def check_moves(movesObj)
		movesObj.moves.each do |m|
			msg = validate_move(@positions[m.split[0].to_sym],@positions[m.split[1].to_sym])
			puts "#{msg ? "LEGAL" : "ILLEGAL"}"	
		end
	end

	def validate_move(orig,dest)
		movingPieceSymbol = get_piece(orig)
		destinationPieceSymbol = get_piece(dest)
		if movingPieceSymbol && !(same_color(movingPieceSymbol,destinationPieceSymbol))	

			pieceAtDestination = get_piece(dest)
			movingPiece = @pieces[movingPieceSymbol].new(movingPieceSymbol)	
			movingPiece.valid_direction(orig,dest)
		else
			false
		end

	end

	def get_piece(location)
		@board[location[0]][location[1]] != :"--" ? @board[location[0]][location[1]] : nil
	end

	def same_color(orig,dest)
		orig.to_s.chr == dest.to_s.chr
	end

end

class Piece
	include Movements
	attr_reader :piece, :color
	def initialize(piece)
		@piece = piece
		@color = @piece.to_s.chr
	end

end

class Pawn < Piece
	def initialize(piece)
		super
		@firstMove = true
	end

	def valid_direction(origin,destination)
		if @firstMove 
			is_vertical(origin,destination) && is_forward(origin,destination) && (is_two_steps(origin,destination) || is_one_step(origin,destination))
		else
			is_vertical(origin,destination) && is_forward(origin,destination) && is_one_step(origin,destination) ? true : false
		end

	end
end

class Rook < Piece
	
	def valid_direction(origin,destination)
		is_horizontal(origin,destination) || is_vertical(origin,destination)
	end
end

class Bishop < Piece
	def valid_direction(origin,destination)
		is_diagonal(origin,destination)
	end
end

class Queen < Piece
	def valid_direction(origin,destination)
		is_diagonal(origin,destination) || is_vertical(origin,destination) || is_horizontal(origin,destination)
	end

end

class King < Piece
	def valid_direction(origin,destination)
		is_one_step(origin,destination)
	end
end

class Knight < Piece
	def valid_direction(origin,destination)
		is_L(origin,destination)
	end
end

# myBoard = Board.new("simple_board.txt")

# myBoard.check_moves(Moves.new("simple_moves.txt"))

myBoard = Board.new("complex_board.txt")

myBoard.check_moves(Moves.new("complex_moves.txt"))

