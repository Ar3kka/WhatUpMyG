class_name Manipulator extends Node3D

const EYES_SCENE : PackedScene = preload("res://Scenes/PlayerComponents/eyes.tscn")

signal found_eyes()
signal found_feet()
signal found_hands()
signal found_mouth()
signal assigned_board()

@export var ID : int :
	set(new_ID): return
	get(): return get_instance_id()
@export var team_id : int = 0 :
	set(new_team_id) :
		var prev_id : int = team_id
		if new_team_id < 0 || !teams_node || teams_node.get_team(new_team_id) == null : new_team_id = 0
		if hands && team_id != new_team_id : hands._deselect()
		team_id = new_team_id
		print("[", self ,"], Username: ", username ," > Changed from team: ", prev_id ,", To team: ", team_id)
		if team_id == 0 : _update_with_all_pieces() ; return
		_update_pieces()
var current_team : Team :
	set(new_team) : team_id = new_team.id
	get() :
		if teams_node == null : return
		return teams_node.get_team(team_id)
		
@export var username : String = "null"
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
@export var mouth : Mouth
var praying : bool :
	get() :
		if mouth == null || !mouth.visible : return false
		return true
@export var moderator : bool = false
@export var initial_board : Board
var current_board : Board :
	set(new_board) :
		if feet == null : return
		feet.board = new_board
	get() :
		if feet == null : return
		return feet.board
var pieces : Array[Piece]
var turn_node : TurnHandler :
	get() :
		if current_board == null : return
		return current_board.turn_node
var teams_node : TeamsHandler :
	get() :
		if current_board == null : return
		return current_board.teams_node
var is_current_turn : bool :
	get() :
		if turn_node == null || !turn_node.active : return true
		return turn_node.can_act(self)

func _ready():
	found_feet.connect(_assign_board)
	found_mouth.connect(func () : mouth.privileges = moderator)
	assigned_board.connect(func () :
		if pieces.is_empty() : current_board.initial_set_generation.connect(_update_pieces)
		else : _update_pieces() )
	
	if eyes == null : _find_eyes()
	else : found_eyes.emit()
	if hands == null : _find_hands()
	else : found_hands.emit()
	if feet == null : _find_feet()
	else : found_feet.emit()
	if mouth == null : _find_mouth()
	else : found_mouth.emit()

func change_team( random : bool = false ) :
	if current_board == null || current_board.teams_node == null : return
	if random : team_id = current_board.teams_node.get_random_team().id
	var current_index : int = current_board.teams_node.get_team(team_id).index
	team_id = current_board.teams_node.get_team_by_index(current_index + 1).id

func _update_with_all_pieces() :
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

func _find_eyes():
	for organ in get_children():
		if organ is Camera3D : eyes = organ ; found_eyes.emit() ; return

func _find_hands():
	for organ in get_children():
		if organ is Hands : hands = organ ; found_hands.emit() ; return

func _find_feet():
	for appendage in get_children():
		if appendage is Feet : feet = appendage ; found_feet.emit() ; return

func _find_mouth():
	for cavity in get_children():
		if cavity is Mouth : mouth = cavity ; found_mouth.emit() ; return
