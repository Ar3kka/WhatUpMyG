class_name SetClassic extends Node

const set_name : String = "classic"
var dna := PieceDNA.new()

func generate() -> PieceSet :
	return populate(PieceSet.new())

func populate( piece_set : PieceSet , force : bool = false ) -> PieceSet :
	if !piece_set.pieces.is_empty() && !force : return

	piece_set.add_row( dna.PAWN, 1, 1, 8 )
	
	piece_set.add_piece( dna.TOWER, 1, Vector2i(0, 0) )
	piece_set.add_piece( dna.HORSE, 1, Vector2i(0, 1) )
	piece_set.add_piece( dna.BISHOP, 1, Vector2i(0, 2) )
	piece_set.add_piece( dna.QUEEN, 1, Vector2i(0, 3) )
	
	piece_set.add_piece( dna.KING, 1, Vector2i(0, 4) )
	piece_set.add_piece( dna.BISHOP, 1, Vector2i(0, 5) )
	piece_set.add_piece( dna.HORSE, 1, Vector2i(0, 6) )
	piece_set.add_piece( dna.TOWER, 1, Vector2i(0, 7) )
	
	return piece_set
