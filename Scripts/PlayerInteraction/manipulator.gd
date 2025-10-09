class_name Manipulator extends Node3D

const EYES_ROTATION : float = -45.0
const EYES_ALTITUDE : float = 2.5
const EYES_DISTANCE : float = 250.0

@export var ID : int :
	set(new_ID): return
	get(): return get_instance_id()
@export var team : int = 0
@export var eyes : Camera3D
@export var eye_sight_distance : float = EYES_DISTANCE
@export var pieces : Array[Piece]
@export var hands : Hands
@export var feet : Feet
@export var nervous_system : MovableComponent
var raycast : RayCast3D = RayCast3D.new()
var mouse_position : Vector3

func _ready():
	if !eyes : _find_eyes()
	if !hands : _find_hands()
	if !feet : _find_feet()
	if !nervous_system : _find_nervous_system()
	eyes.add_child(raycast)

func _find_eyes():
	for organ in get_children():
		if organ is Camera3D : eyes = organ
	if !eyes : eyes = Camera3D.new()
	eyes.rotation.x = EYES_ROTATION
	eyes.position.y = EYES_ALTITUDE

func _find_hands():
	for organ in get_children():
		if organ is Hands : hands = organ

func _find_feet():
	for appendage in get_children():
		if appendage is Feet : feet = appendage

func _find_nervous_system():
	for organ in get_children():
		if organ is MovableComponent : nervous_system = organ
