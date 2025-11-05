class_name Board extends Node3D

signal found_grid()
signal initial_grid_generation()
signal initial_set_generation()

@export var grid : TileGrid

@export var teams_node : TeamsHandler
var teams : Array[Node] :
	get() : 
		if teams_node == null : return []
		return teams_node.get_children()

@export var pieces_node : PieceGenerator
var pieces : Array[Piece] :
	get() :
		if pieces_node == null : return []
		return pieces_node.pieces

var god := RandomNumberGenerator.new()
@export var seed := ""

func _ready() -> void:
	
	var seed_to_use : int = hash( seed ) if seed else randi()
	god.seed = seed_to_use
	print("BOARD: ", self, " | SEED NAME: ", seed, "| SEED ID: ", god.seed)
	
	found_grid.connect(func() : grid.generate_rows() )
	
	if grid == null : _find_grid()
	if pieces_node == null : _find_pieces_node()
	if teams_node == null : _find_teams_node()

func get_pieces() -> Array[Piece] :
	if pieces_node == null : return []
	return pieces_node.get_pieces()

func get_specific_pieces( selectable : bool, playable : bool, alive : bool, team : int = 0, either_or : bool = false ) -> Array[Piece] :
	if pieces_node == null : return []
	return pieces_node.get_specific_pieces(selectable, playable, alive, team, either_or)

func _find_grid() :
	for child in get_children():
		if child is TileGrid : grid = child ; found_grid.emit() ; return

func _find_pieces_node() :
	for child in get_children():
		if child is PieceGenerator : pieces_node = child ; return

func _find_teams_node() :
	for child in get_children():
		if child is TeamsHandler : teams_node = child ; return

#func _instantiate_grid() :
#	if grid != null : return
#	var new_grid = grid_template.instantiate(generation_grid_size, randomize, generation_direction)
#	if force_pattern : new_grid.force_pattern = force_pattern
#	if color_pattern : new_grid.color_pattern = color_pattern
#	if color_switch : new_grid.color_switch = color_switch
#	new_grid.board = self
#	add_child(new_grid)
#	grid_generated.emit()
