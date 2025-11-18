class_name SetClassic extends Node

var dna := PieceDNA.new()

func populate( piece_set : PieceSet , force : bool = false, negative : bool = true ):
	if !piece_set.templates.is_empty() && !force : return

	piece_set.add_row( dna.PAWN, 1, 1, 8 )
	
	piece_set.add_piece( dna.TOWER, 1, Vector2i(0, 0) )
	piece_set.add_piece( dna.HORSE, 1, Vector2i(0, 1) )
	piece_set.add_piece( dna.BISHOP, 1, Vector2i(0, 2) )
	piece_set.add_piece( dna.QUEEN, 1, Vector2i(0, 3) )
	
	piece_set.add_piece( dna.KING, 1, Vector2i(0, 4) )
	piece_set.add_piece( dna.BISHOP, 1, Vector2i(0, 5) )
	piece_set.add_piece( dna.HORSE, 1, Vector2i(0, 6) )
	piece_set.add_piece( dna.TOWER, 1, Vector2i(0, 7) )
	
	if !negative : return
	
	piece_set.add_specific_piece( dna.generate_piece( dna.PAWN, 2, Vector2i(5, 5), 10 ) )
	
	piece_set.add_row( dna.PAWN, 2, 6, 8 )
	
	piece_set.add_piece( dna.TOWER, 2, Vector2i(7, 0) )
	piece_set.add_piece( dna.TOWER, 2, Vector2i(7, 7) )
	
	piece_set.add_piece( dna.HORSE, 2, Vector2i(7, 1) )
	piece_set.add_piece( dna.HORSE, 2, Vector2i(7, 6) )
	
	piece_set.add_piece( dna.BISHOP, 2, Vector2i(7, 2) )
	piece_set.add_piece( dna.BISHOP, 2, Vector2i(7, 5) )
	
	piece_set.add_piece( dna.QUEEN, 2, Vector2i(7, 4) )
	piece_set.add_piece( dna.KING, 2, Vector2i(7, 3) )
