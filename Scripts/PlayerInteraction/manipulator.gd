class_name Manipulator extends Node3D

const EYES_SCENE : PackedScene = preload("res://Scenes/PlayerComponents/eyes.tscn")

signal found_eyes()
signal found_feet()
signal found_hands()
signal assigned_board()

@export var ID : int :
	set(new_ID): return
	get(): return get_instance_id()
@export var team_id : int = 0 :
	set(new_team) :
		team_id = new_team
		if team_id == 0 : _update_with_all_pieces() ; return
		_update_pieces()
@export var eyes : Camera3D :
	set(new_eyes) :
		eyes = new_eyes
		if eyes != null : found_eyes.emit()
@export var hands : Hands :
	set(new_hands) :
		hands = new_hands
		if hands != null : found_hands.emit()
@export var feet : Feet :
	set(new_feet) :
		feet = new_feet
		if feet != null : found_feet.emit()
@export var initial_board : Board
var current_board : Board :
	get() :
		if feet == null : return
		return feet.board
var pieces : Array[Piece]

func _ready():
	
	found_feet.connect(_assign_board)
	assigned_board.connect(func () :
		if pieces.is_empty() : current_board.initial_set_generation.connect(_update_pieces)
		else : _update_pieces() )
	
	if eyes == null : _find_eyes()
	else : found_eyes.emit()
	if hands == null : _find_hands()
	else : found_hands.emit()
	if feet == null : _find_feet()
	else : found_feet.emit()

func _update_with_all_pieces( ) :
	if current_board == null : return
	pieces.clear()
	pieces.append_array( current_board.get_pieces() )

func _update_pieces( selectable : bool = true, playable : bool = true, alive : bool = true, either_or : bool = false ) :
	if current_board == null : return
	pieces.clear()
	pieces = current_board.get_specific_pieces(selectable, playable, alive, team_id, either_or)

func _assign_board() :
	if feet == null : return
	feet.board = initial_board
	if initial_board != null : assigned_board.emit()

func _find_eyes():
	for organ in get_children():
		if organ is Camera3D : eyes = organ ; return

func _find_hands():
	for organ in get_children():
		if organ is Hands : hands = organ ; return

func _find_feet():
	for appendage in get_children():
		if appendage is Feet : feet = appendage ; return
