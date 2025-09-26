class_name Manipulator extends Node3D

const EYES_ROTATION : float = -45.0
const EYES_ALTITUDE : float = 2.5
const EYES_DISTANCE : float = 250.0

@export var ID : String
@export var team : int = 0
@export var eyes : Camera3D
@export var eye_sight_distance : float = EYES_DISTANCE
@export var pieces : Array[Piece]
var raycast : RayCast3D = RayCast3D.new()

func _ready():
	if !eyes : _find_eyes()
	eyes.add_child(raycast)

func _find_eyes():
	for organ in get_children():
		if organ is Camera3D : eyes = organ
	if !eyes : eyes = Camera3D.new()
	eyes.rotation.x = EYES_ROTATION
	eyes.position.y = EYES_ALTITUDE
