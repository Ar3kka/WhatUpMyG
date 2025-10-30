class_name PieceGenerator extends Node3D

signal generated_piece()

@export var board : Board
@export var spawn_point : Vector3 = Vector3.ZERO :
	get() :
		if grid == null : return spawn_point
		return grid.center_point
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
var initial_set : PieceSet

func _ready() -> void:
	if board == null : board = get_parent_node_3d()
	dna.god = god
	var template_set := PieceSet.new()
	template_set.add_piece(dna.PAWN, 1, Vector2i(1,0))
	template_set.add_piece(dna.PAWN, 1, Vector2i(1,1))
	template_set.add_piece(dna.PAWN, 1, Vector2i(1,2))
	template_set.add_piece(dna.PAWN, 1, Vector2i(1,3))
	template_set.add_piece(dna.PAWN, 1, Vector2i(1,4))
	
	
	board.found_grid.connect(func() :
		grid.generate_rows()
		add_set(initial_set)
		fill_row( dna.PAWN, 1, 1 )
		fill_row( dna.PAWN, 2, 6 )
		
		add_piece( dna.TOWER, 1, Vector2i(0, 0) )
		add_piece( dna.TOWER, 1, Vector2i(0, 7) )
		add_piece( dna.TOWER, 2, Vector2i(7, 0) )
		add_piece( dna.TOWER, 2, Vector2i(7, 7) )
		
		add_piece( dna.BISHOP, 1, Vector2i(0, 2) )
		add_piece( dna.BISHOP, 1, Vector2i(0, 5) )
		add_piece( dna.BISHOP, 2, Vector2i(7, 2) )
		add_piece( dna.BISHOP, 2, Vector2i(7, 5) )
		
		add_piece( dna.HORSE, 1, Vector2i(0, 1) )
		add_piece( dna.HORSE, 1, Vector2i(0, 6) )
		add_piece( dna.HORSE, 2, Vector2i(7, 1) )
		add_piece( dna.HORSE, 2, Vector2i(7, 6) )
		
		add_piece( dna.QUEEN, 1, Vector2i(0, 3) )
		add_piece( dna.QUEEN, 2, Vector2i(7, 4) )
		
		add_piece( dna.KING, 1, Vector2i(0, 4) )
		add_piece( dna.KING, 2, Vector2i(7, 3) )
		)

func add_set( piece_set : PieceSet ) :
	if piece_set == null : return
	for piece in piece_set.templates :
		add_specific_piece(piece)

func fill_row( piece_dna : PackedScene, team_id : int, row : int = 0 ) :
	if grid == null || grid.is_empty : return
	if grid.tiles[row] == null || (row - 1) > grid.tiles.size() : row = grid.tiles.size() - 1
	for index in range(grid.tiles[row].size()) :
		add_specific_piece( generate_piece( piece_dna, team_id, Vector2i(row, index) ), false )

func generate_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i ) -> Piece :
	if grid == null || grid.is_empty : return
	var piece : Piece = piece_dna.instantiate()
	piece.mother = self
	piece.initial_team = teams.get_team(team_id)
	piece.initial_coordinates = coordinates
	return piece

func add_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i ) :
	if grid == null || grid.is_empty : return
	var piece : Piece = generate_piece( piece_dna, team_id, coordinates )
	add_child(piece)
	generated_piece.emit()

func add_specific_piece( piece : Piece , team_from_id : bool = true ) :
	if grid == null || grid.is_empty : return
	piece.mother = self
	if team_from_id : piece.initial_team = teams.get_team(piece.initial_team_id)
	add_child(piece)
	generated_piece.emit()

func add_random_piece( team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, grid.get_random_coordinates() )
	
func add_random_piece_at( coordinates : Vector2i, team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, coordinates )
