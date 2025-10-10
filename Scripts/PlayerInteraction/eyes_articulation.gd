class_name Eyes extends Camera3D

signal locked_in()

const IMAGINATION_SCENE : PackedScene = preload("res://Scenes/PlayerComponents/imagination.tscn")

const EYES_ROTATION : float = -45.0
const EYES_ALTITUDE : float = 2.5
const EYES_DISTANCE : float = 250.0

@export var body : Manipulator
@export var active : bool = true
@export var pupils : RayCast3D 
@export var eye_sight_distance : float = EYES_DISTANCE

## Potentially an interactable object.
var potential_momma : 
	set(new_value) : return
	get() : return pupils.get_collider()
## Gorgeous big momma (Draggable_component)
var big_momma : DraggableComponent :
	set(new_eye_taco) :
		big_momma = new_eye_taco
		locked_in.emit()
## The position of the currently seen beauty.
var booty : Vector3  :
	set(new_booty) : return
	get() : 
		if big_momma == null : return booty 
		return big_momma.body_position
## The mouse position.
var focus_point : Vector2 :
	set(new_value) : return
	get() : return get_viewport().get_mouse_position()
## The ray origin
var optic_nerve : 
	get() : return project_ray_origin(focus_point) 
## The ray's end
var cornea :
	set(new_value) : return
	get() : return project_ray_normal(focus_point) 
## The ray's depth
var lens :
	set(new_value) : return
	get() : return optic_nerve.distance_to(booty)
## The final ray's position
var sight :
	set(new_value) : return
	get() : return optic_nerve + cornea * lens # final_ray_position

func _ready():
	if !body : body = get_parent_node_3d()
	if !pupils : pupils = RayCast3D.new()
	add_child(IMAGINATION_SCENE.instantiate())
	add_child(pupils)

	rotation.x = EYES_ROTATION
	position.y = EYES_ALTITUDE

func blink(force : bool = true): 
	pupils.target_position = project_local_ray_normal(focus_point) * eye_sight_distance
	if force : pupils.force_raycast_update()

func _process(delta: float) -> void:
	if !active : return
