class_name PieceSet extends Node

var dna : PieceDNA
var setdna : SetDNA

var default : bool = true
var set_name : String = ""
var templates : Array[Piece] = []

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
