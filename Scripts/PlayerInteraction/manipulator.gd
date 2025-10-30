class_name Manipulator extends Node3D

const EYES_SCENE : PackedScene = preload("res://Scenes/PlayerComponents/eyes.tscn")

signal found_eyes()
signal found_feet()
signal found_hands()
signal assigned_board()

@export var ID : int :
	set(new_ID): return
	get(): return get_instance_id()
@export var team_id : int = 0
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
@export var pieces : Array[Piece]

func _ready():
	
	found_feet.connect(_assign_board)
	
	if eyes == null : _find_eyes()
	else : found_eyes.emit()
	if hands == null : _find_hands()
	else : found_hands.emit()
	if feet == null : _find_feet()
	else : found_feet.emit()

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
