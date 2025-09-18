extends Node3D
class_name health_component

signal hit(damage_points : float)

@export var body : RigidBody3D
@export var body_area := Area3D
@export var alive := true
@export var health_points := 1.0
@export var invincible_time := 2.0

func _check_alive() -> bool : return health_points > 0

func _on_health_area_area_entered(area: Area3D):
	if area.get_parent_node_3d().body == body: return
	#print(get_parent(), " soy al que le pican en: ", area)

func _on_ready():
	if !body : body = get_parent()
	hit.connect(func(damage_points : float):
		health_points -= damage_points
		print(body,": ouch, those ", damage_points, " really hurt, now I'm at: ", health_points, " alive: ", _check_alive()))
