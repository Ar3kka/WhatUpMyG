class_name PieceSet extends Node

var dna := PieceDNA.new()

var set_name : String = ""
var templates : Array[Piece] = []

func _ready() -> void:
	add_row( dna.PAWN, 1, 1, 7 )
	add_row( dna.PAWN, 2, 6, 7 )
	
	add_piece( dna.TOWER, 1, Vector2i(0, 0) )
	add_piece( dna.TOWER, 1, Vector2i(0, 7) )
	add_piece( dna.TOWER, 2, Vector2i(7, 0) )
	add_piece( dna.TOWER, 2, Vector2i(7, 7) )
	
	add_piece( dna.HORSE, 1, Vector2i(0, 1) )
	add_piece( dna.HORSE, 1, Vector2i(0, 6) )
	add_piece( dna.HORSE, 2, Vector2i(7, 1) )
	add_piece( dna.HORSE, 2, Vector2i(7, 6) )
	
	add_piece( dna.BISHOP, 1, Vector2i(0, 2) )
	add_piece( dna.BISHOP, 1, Vector2i(0, 5) )
	add_piece( dna.BISHOP, 2, Vector2i(7, 2) )
	add_piece( dna.BISHOP, 2, Vector2i(7, 5) )
	
	add_piece( dna.QUEEN, 1, Vector2i(0, 3) )
	add_piece( dna.QUEEN, 2, Vector2i(7, 4) )
	
	add_piece( dna.KING, 1, Vector2i(0, 4) )
	add_piece( dna.KING, 2, Vector2i(7, 3) )

func add_specific_piece( piece : Piece ) :
	templates.append(piece)

func add_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i ) :
	var piece : Piece = generate_piece(piece_dna, team_id, coordinates)
	templates.append(piece)

func generate_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i ) -> Piece :
	var piece : Piece = piece_dna.instantiate()
	piece.initial_team_id = team_id
	piece.initial_coordinates = coordinates
	return piece

func add_row( piece_dna : PackedScene, team_id : int, row : int, amount : int = 0 ) :
	for index in range(amount) :
		add_specific_piece( generate_piece( piece_dna, team_id, Vector2i(row, index) ) )
