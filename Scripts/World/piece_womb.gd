class_name PieceGenerator extends Node3D

signal generated_piece()

@export var board : Board
var dna := PieceDNA.new()
var grid : TileGrid :
	get():
		if board == null : return
		return board.grid
var teams : TeamsHandler :
	get():
		if board == null : return
		return board.teams_node
var god : RandomNumberGenerator :
	get():
		if board == null : return RandomNumberGenerator.new()
		return board.god

func _ready() -> void:
	if board == null : board = get_parent_node_3d()
	dna.god = god
	
	board.found_grid.connect(func() :
		grid.generate_rows()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece()
		add_random_piece() )

func add_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i ) :
	if grid == null || grid.is_empty : return
	var piece : Piece = piece_dna.instantiate()
	piece.mother = self
	piece.initial_team = teams.get_team(team_id)
	piece.initial_coordinates = coordinates
	add_child(piece)
	generated_piece.emit()

func add_random_piece( team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, grid.get_random_coordinates() )
	
func add_random_piece_at( coordinates : Vector2i, team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, coordinates )
