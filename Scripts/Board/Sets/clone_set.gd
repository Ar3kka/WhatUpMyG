class_name SetClone extends Node

const set_name : String = "clone" 
var dna := PieceDNA.new()

func generate( piece_dna : PackedScene = dna.PAWN , rows : int = 2 ) -> PieceSet :
	return populate(PieceSet.new(), piece_dna, rows)

func populate( piece_set : PieceSet, piece_dna : PackedScene, rows : int = 2, force : bool = false ) -> PieceSet :
	if !piece_set.pieces.is_empty() && !force : return
	
	for row in rows :
		piece_set.add_row( piece_dna, 1, row, 8 )
	
	return piece_set
