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
	def is_horizontal(o,d)
		o[0] == d[0] ? true : false
	end

	def is_vertical(o,d)
		o[1] == d[1] ? true : false
	end

	def is_diagonal(o,d)

		diffO = o.max - o.min
		diffD = d.max - d.min

		diffX = (o[0] - d[0]).abs
		diffY = (o[1] - d[1]).abs

		#diffX == diffY && diffO == diffD ? true : false
		diffX == diffY ? true : false

	end

	def is_one_step(o,d)
		if is_vertical(o,d) 
			(d[0]-o[0]).abs == 1 ? true : false
		elsif is_horizontal(o,d)
			(d[1]-o[1]).abs == 1 ? true : false
		else #is_diagonal(o,d)
			(d[0]-o[0]).abs && (d[1]-o[1]).abs == 1 ? true : false

		end

	end
	
	def is_two_steps(o,d)
		(d[0]-o[0]).abs == 2 || (d[1]-o[1]).abs == 2 ? true : false
	end

	def is_forward(o,d)
		#binding.pry
		if @color == "w"
			d[0] > o[0] ? true : false
		elsif @color == "b"
			d[0] < o[0] ? true : false
		end
	end
	
	def is_L(o,d)
		#binding.pry
		!is_vertical(o,d) && !is_horizontal(o,d) && !is_diagonal(o,d) && is_two_steps(o,d)		
	end
end

class Moves
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
		# @positions = { a1: [], a2: [], a3: [], a4: [], a5: [], a6: a7: a8:
		# 				1,2,3,4,5,6,7,8

		# 		}
	end

	def set_board(boardfile)
		input = get_contents(boardfile)
		input.map! { |i| i.split(" ") }

		input.each do |i|
			i.map! { |j| j.to_sym }
		end

		input
	end

	def get_piece(pos)
		
	

	end

	def validate_move(orig,dest)

		myPiece = @pieces[@board[orig[0]][orig[1]]].new(@board[orig[0]][orig[1]])
		puts "orig #{orig} dest #{dest} valid? #{myPiece.valid_direction(orig,dest)}"
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

	def valid_direction(o,d)
		#binding.pry
		if @firstMove 
			is_vertical(o,d) && is_forward(o,d) && (is_two_steps(o,d) || is_one_step(o,d))
		else
			is_vertical(o,d) && is_forward(o,d) && is_one_step(o,d) ? true : false
		end

	end
end

class Rook < Piece
	
	def valid_direction(o,d)
		is_horizontal(o,d) || is_vertical(o,d)
	end
end

class Bishop < Piece
	def valid_direction(o,d)
		is_diagonal(o,d)
	end
end

class Queen < Piece

	def valid_direction(o,d)
		is_diagonal(o,d) || is_vertical(o,d) || is_horizontal
	end


end

class King < Piece
	def valid_direction(o,d)
		is_one_step(o,d)
	end
end

class Knight < Piece
	def valid_direction(o,d)
		is_L(o,d)
	end
end

myBoard = Board.new("simple_board.txt")
myMoves = Moves.new("simple_moves.txt")

pos = [0,0]
des = [1,0]
#puts "position #{pos} #{myBoard.get_piece(pos)}"
puts "legal move #{pos} #{des} #{myBoard.validate_move(pos,des)}"
# #myBoard.set_board
# puts myBoard.inspect



#bQ = Queen.new(:bQ)
# puts "a1 to a8: #{bQ.valid_direction([0,0],[0,8])}" #true
# puts "a1 to h8: #{bQ.valid_direction([0,0],[8,0])}" #true
# puts "a1 to b4: #{bQ.valid_direction([0,0],[3,1])}" #true - diagonal
# puts "b3 to a2: #{bQ.valid_direction([2,1],[1,0])}" #true - diagonal
# puts "b3 to b3: #{bQ.valid_direction([2,1],[2,1])}" #true - diagonal

#bB = Bishop.new(:bB)
# puts "a1 to a8: #{bB.piece} #{bB.valid_direction([0,0],[0,8])}" #false
# puts "a1 to h8: #{bB.piece} #{bB.valid_direction([0,0],[8,0])}" #false
# puts "a1 to b4: #{bB.piece} #{bB.valid_direction([0,0],[3,3])}" #true - diagonal
# puts "b3 to a2: #{bB.piece} #{bB.valid_direction([2,1],[1,0])}" #true - diagonal


#bR = Rook.new(:bR)

# puts "a1 to a8: #{bR.piece} #{bR.valid_direction([0,0],[0,8])}" #true
# puts "a1 to h8: #{bR.piece} #{bR.valid_direction([0,0],[8,0])}" #true
# puts "a1 to b4: #{bR.piece} #{bR.valid_direction([0,0],[3,1])}" #false - diagonal

#bK = King.new(:bK)
# puts "a1 to a8: #{bK.piece} #{bK.valid_direction([0,0],[0,8])}" #false
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([0,0],[8,0])}" #false
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([1,1],[1,2])}" #true
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([1,1],[0,2])}" #true
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([1,1],[0,1])}" #true
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([1,1],[0,0])}" #true
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([1,1],[1,0])}" #true
# puts "a1 to h8: #{bK.piece} #{bK.valid_direction([1,1],[2,0])}" #true





#wP = Pawn.new(:wP)
#bP = Pawn.new(:bP)
	
# puts "#{wP.piece} #{wP.valid_direction([0,0],[2,0])}" #true
# puts "#{wP.piece} #{wP.valid_direction([0,0],[0,1])}" #false
# puts "#{wP.piece} #{wP.valid_direction([0,0],[1,0])}" #true
# puts "#{wP.piece} #{wP.valid_direction([0,0],[0,2])}" #false
# puts "#{wP.piece} #{wP.valid_direction([7,0],[5,0])}" #false 

# puts "#{bP.piece} #{bP.valid_direction([7,0],[5,0])}" #true
# puts "#{bP.piece} #{bP.valid_direction([7,0],[5,0])}" #true

bN = Knight.new(:bN)
# puts "#{bN.piece} #{bN.valid_direction([2,3],[4,4])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[3,5])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[1,5])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[0,4])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[0,2])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[1,1])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[3,1])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[4,2])}" #true
# puts "#{bN.piece} #{bN.valid_direction([2,3],[3,3])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[3,4])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[2,4])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[1,4])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[1,3])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[4,1])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[4,3])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[4,5])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[2,5])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[0,5])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[0,3])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[0,1])}" #false
# puts "#{bN.piece} #{bN.valid_direction([2,3],[2,1])}" #false