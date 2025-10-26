class_name PieceDNA extends Node3D

var god : RandomNumberGenerator

const TEMPLATE : PackedScene = preload("res://Scenes/Pieces/piece.tscn")

## ORIGINAL SET

const PAWN : PackedScene = preload("res://Scenes/Pieces/pawn.tscn") # 1
const KING : PackedScene = preload("res://Scenes/Pieces/king.tscn") # 2
const QUEEN : PackedScene = preload("res://Scenes/Pieces/queen.tscn") # 3
const HORSE : PackedScene = preload("res://Scenes/Pieces/horse.tscn") # 4
const TOWER : PackedScene = preload("res://Scenes/Pieces/tower.tscn") # 5
const BISHOP : PackedScene = preload("res://Scenes/Pieces/bishop.tscn") # 6

const total_dna : int = 6

func get_random_dna() -> PackedScene :
	match god.randi_range(1, total_dna) :
		2 : return KING
		3 : return QUEEN
		4 : return HORSE
		5 : return TOWER
		6 : return BISHOP
	return PAWN
