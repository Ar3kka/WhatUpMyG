class_name PieceSet extends Node

var dna := PieceDNA.new()
var setdna : SetDNA

var default : bool = true
var set_name : String = ""
var templates : Array[Piece] = []

func add_specific_piece( piece : Piece, coordinates : Vector2i = piece.initial_coordinates ) :
	piece.initial_coordinates = coordinates
	templates.append(piece)

func add_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i ) :
	var piece : Piece = dna.generate_piece( piece_dna, team_id, coordinates )
	templates.append(piece)

func add_row( piece_dna : PackedScene, team_id : int, row : int, amount : int = 0 ) :
	for index in range(amount) :
		add_specific_piece( dna.generate_piece( piece_dna, team_id, Vector2i(row, index) ) )
