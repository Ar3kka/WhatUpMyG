class_name Board extends Node3D

signal restarted

const SCENE : PackedScene = preload("res://Scenes/World/board.tscn")

signal found_set_handler()
signal found_piece_handler()
signal found_teams_handler()
signal found_turn_handler()
signal found_grid()
signal found_god()
signal initial_grid_generation()
signal initial_set_generation()

@export var god : God
var miracle : RandomNumberGenerator :
	get() :
		if god == null : return
		return god.miracle
@export var grid : TileGrid

@export var teams_node : TeamsHandler
var teams : Array[Node] :
	get() : 
		if teams_node == null : return []
		return teams_node.get_children()

@export var turn_node : TurnHandler
@export var set_node : SetHandler
var initial_set : PieceSet :
	set(new_initial_set) :
		if pieces_node == null : return
		pieces_node.initial_set = new_initial_set
	get() :
		if pieces_node == null : return
		return pieces_node.initial_set
@export var pieces_node : PieceGenerator
var pieces : Array[Piece] :
	get() :
		if pieces_node == null : return []
		return pieces_node.pieces
@export var initial_seed : String = ""
var seed : int :
	set(new_seed) : 
		if miracle == null : return
		miracle.seed = new_seed
	get() :
		if miracle == null : return -1
		return miracle.seed
@export var initial_size : Vector2i = Vector2i.ZERO
var size : Vector2i :
	get() :
		if grid == null : return Vector2i.ZERO
		return grid.grid_size
var manipulators : Array[Manipulator] = []

func _ready() -> void:
	found_grid.connect(_on_grid_found)
	_start()

func _on_grid_found() :
	if grid == null : return
	if initial_size != Vector2i.ZERO : grid.generation_grid_size = initial_size
	grid.generate_rows()

func _start() :
	if god == null : _find_god()
	else : found_god.emit()
	
	seed = hash( initial_seed ) if initial_seed or !initial_seed.is_empty() else randi()
	print("BOARD: ", self, " | SEED NAME: ", initial_seed, " | SEED ID: ", seed, " | DIMENSIONS [ X:", initial_size.x, ", Y:", initial_size.x, " ]")
	
	if grid == null : _find_grid()
	else : found_grid.emit()
	if pieces_node == null : _find_pieces_node()
	else : found_piece_handler.emit()
	if teams_node == null : _find_teams_node()
	else : found_teams_handler.emit()
	if turn_node == null : _find_turn_handler_node()
	else : found_turn_handler.emit()
	if set_node == null : _find_set_handler_node()
	else : found_set_handler.emit()

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
		if child is PieceGenerator : pieces_node = child ; found_piece_handler.emit() ; return

func _find_teams_node() :
	for child in get_children():
		if child is TeamsHandler : teams_node = child ; found_teams_handler.emit() ; return
		
func _find_turn_handler_node() :
	for child in get_children():
		if child is TurnHandler : turn_node = child ; found_turn_handler.emit() ; return

func _find_set_handler_node() :
	for child in get_children():
		if child is SetHandler : set_node = child ; found_set_handler.emit() ; return

func _find_god() :
	for child in get_children():
		if child is God : god = child ; found_god.emit() ; return

func replace(requester : Manipulator, new_board : Board) :
	var parent := get_parent()
	if god : god.clone_to(new_board.god)
	requester.current_board = new_board
	parent.add_child(new_board)
	new_board.restarted.emit()
	queue_free()

func restart(requester : Manipulator, _initial_seed : String = initial_seed, _initial_set : PieceSet = initial_set, _initial_size : Vector2i = grid.STANDARD_GENERATION_SIZE if grid else Vector2i(8, 8)) :
	var new_board : Board = instantiate(_initial_seed, _initial_set, _initial_size)
	var parent := get_parent()
	if god : god.clone_to(new_board.god)
	requester.current_board = new_board
	parent.add_child(new_board)
	new_board.restarted.emit()
	queue_free()

func instantiate(_initial_seed : String = initial_seed, _initial_set : PieceSet = initial_set, _initial_size : Vector2i = grid.STANDARD_GENERATION_SIZE if grid else Vector2i(8, 8)) -> Board:
	var new_board : Board = SCENE.instantiate()
	new_board.initial_seed = _initial_seed
	new_board.initial_set = _initial_set
	new_board.initial_size = _initial_size
	return new_board
