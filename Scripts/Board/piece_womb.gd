class_name PieceGenerator extends Node3D

signal generated_piece(piece : Piece)
signal generated_set()
signal generated_initial_set()

@export var board : Board
@export var add_set_on_start : bool = true
@export var default_set : bool = true
@export var add_random_pieces_on_start : bool = true
@export var spawn_point : Vector3 = Vector3.ZERO :
	get() :
		if grid == null : return spawn_point
		return grid.center_point
var dna := PieceDNA.new()
var set_node : SetHandler :
	get():
		if board == null : return
		return board.set_node
var grid : TileGrid :
	get():
		if board == null : return
		return board.grid
var grid_size : Vector2i :
	get():
		if grid == null : return Vector2i.ZERO
		return grid.grid_size
var teams : TeamsHandler :
	get():
		if board == null : return
		return board.teams_node
var miracle : RandomNumberGenerator :
	get():
		if board == null : return RandomNumberGenerator.new()
		return board.miracle
var initial_set : PieceSet
var _initial_set_generation : bool = false
var pieces : Array[Piece] = []

func _ready() -> void:
	if board == null : board = get_parent_node_3d()

	if board && board.god : dna.god = board.god
	
	board.found_grid.connect(func() : 
		grid.initial_generation.connect(func() : 
			board.found_set_handler.connect(populate) ) )
	
	generated_piece.connect(func(new_piece : Piece) : pieces.append(new_piece))
	
	generated_set.connect(_on_set_generation)

func _on_set_generation() :
	if _initial_set_generation : return
	_initial_set_generation = true
	generated_initial_set.emit()
	if board : board.initial_set_generation.emit()

func populate(add_initial_set : bool = add_set_on_start, random_pieces : bool = add_random_pieces_on_start) :
	if add_initial_set : add_set(initial_set)
	if random_pieces : add_random_pieces()
	update_pieces()

func reset(_initial_set : PieceSet = initial_set) :
	initial_set = _initial_set
	_initial_set_generation = false
	if pieces.size() < 1 : return
	for child in get_children() :
		if child is Piece : child.queue_free()
	pieces.clear()
	
	add_random_piece()

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
	if piece_set.pieces.is_empty() && piece_set.default : set_node.populate_by_index(piece_set, 0)
	for piece in piece_set.pieces :
		add_specific_piece(piece)
	generated_set.emit()

func fill_row( piece_dna : PackedScene, team_id : int, row : int = 0 ) :
	if grid == null || grid.is_empty : return
	if grid.tiles[row] == null || (row - 1) > grid.tiles.size() : row = grid.tiles.size() - 1
	for index in range(grid.tiles[row].size()) :
		add_specific_piece( generate_piece( piece_dna, team_id, Vector2i(row, index) ), false )

func generate_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i, force_connect : bool = false ) -> Piece :
	if grid == null || grid.is_empty : return
	var piece : Piece = piece_dna.instantiate()
	piece.mother = self
	piece.initial_team = teams.get_team(team_id)
	piece.initial_coordinates = coordinates
	piece.force_connect_on_coordinates = force_connect
	return piece

func add_piece( piece_dna : PackedScene, team_id : int, coordinates : Vector2i, force_connect : bool = false ) :
	if grid == null || grid.is_empty : return
	var piece : Piece = generate_piece( piece_dna, team_id, coordinates, force_connect )
	add_child(piece)
	generated_piece.emit(piece)

func add_specific_piece( piece : Piece , team_from_id : bool = true) :
	if grid == null || grid.is_empty : return
	piece.mother = self
	if team_from_id : piece.initial_team = teams.get_team(piece.initial_team_id)
	add_child(piece)
	generated_piece.emit(piece)

func add_random_pieces(team_id : int = teams.get_random_team().id, n_pieces : int = miracle.randi_range(1, grid_size.y)) :
	if grid == null || grid.is_empty : return
	for i in n_pieces : add_piece( dna.get_random_dna(), team_id, grid.get_random_coordinates() )

func add_random_piece( team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, grid.get_random_coordinates() )
	
func add_random_piece_at( coordinates : Vector2i, team_id : int = teams.get_random_team().id ) :
	if grid == null || grid.is_empty : return
	add_piece( dna.get_random_dna(), team_id, coordinates )
