class_name PieceGenerator extends Node3D

signal generated_piece(piece : Piece)
signal generated_set()
signal generated_initial_set()

@export var board : Board
@export var default_set : bool = false
@export var spawn_point : Vector3 = Vector3.ZERO :
	get() :
		if grid == null : return spawn_point
		return grid.center_point
var dna := PieceDNA.new()
var setdna := SetDNA.new()
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
var _initial_set_generation : bool = false
var pieces : Array[Piece] = []

func _ready() -> void:
	if board == null : board = get_parent_node_3d()
	
	dna.god = god
	setdna.god = god
	
	board.found_grid.connect(func() : 
		grid.initial_generation.connect(func () : 
			add_set(initial_set)
			update_pieces() ) )
	
	generated_piece.connect(func(new_piece : Piece) : pieces.append(new_piece))
	
	generated_set.connect(func() :
		if _initial_set_generation : return
		_initial_set_generation = true
		generated_initial_set.emit()
		if board : board.initial_set_generation.emit() )
		

func update_pieces() : 
	pieces.clear()
	pieces = get_pieces()

func get_piece_at(x : int = 0, y : int = 0) -> Piece :
	var coordinates := Vector2i(x, y)
	for piece in pieces :
		if piece.current_coordinates == coordinates : return piece
	return null

func get_pieces() -> Array[Piece] : 
	var result : Array[Piece] = []
	for node in get_children() :
		if node is Piece : result.append(node)
	return result

func get_specific_pieces( selectable : bool, playable : bool, alive : bool, team : int = 0, either_or : bool = false ) :
	var final_array : Array[Piece] = []
	for piece in pieces :
		if either_or :
			if ( ( playable && piece.playable_component ) || 
			( selectable && piece.selectable_component ) ||
			( alive && piece.is_alive ) ||
			( team == piece.team_id ) ) : 
				final_array.append(piece)
		else :
			if ( ( !playable || ( playable && piece.playable_component ) ) && 
			( !selectable || ( selectable && piece.selectable_component ) ) &&
			( !alive || ( alive && piece.is_alive ) ) &&
			( team == piece.team_id ) ) : 
				final_array.append(piece)
	return final_array 

func add_set( piece_set : PieceSet ) :
	if piece_set == null && !default_set : return
	if piece_set == null : piece_set = PieceSet.new()
	if piece_set.templates.is_empty() && piece_set.default : setdna.default(piece_set)
	for piece in piece_set.templates :
		add_specific_piece(piece)
	generated_set.emit()

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
	generated_piece.emit(piece)

func add_specific_piece( piece : Piece , team_from_id : bool = true ) :
	if grid == null || grid.is_empty : return
	piece.mother = self
	if team_from_id : piece.initial_team = teams.get_team(piece.initial_team_id)
	add_child(piece)
	generated_piece.emit(piece)

func add_random_piece( team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, grid.get_random_coordinates() )
	
func add_random_piece_at( coordinates : Vector2i, team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, coordinates )
