extends Node3D

@export var body : RigidBody3D
@export var dragging_strength : float = 10.0
@export var active : bool = true

var being_dragged : bool = false
var target_position: Vector3

func _ready() -> void:
	if !body : body = get_parent_node_3d()

# call in your player code whenever they start grabbing the object
func start_dragging() -> void:
	being_dragged = true
	body.gravity_scale = 0

# call in your player code every physics tick with the global position
# that theyre "holding" the object at
func process_dragging(grab_point: Vector3) -> void:
	target_position = grab_point

# call in your player code whenever they stop grabbing the object
func stop_dragging() -> void:
	being_dragged = false
	body.gravity_scale = 1

func _physics_process(delta: float) -> void:
	if being_dragged && active:
		body.linear_velocity = dragging_strength * (target_position - global_position)
		print("what")
