extends Node3D
class_name HealthComponent

signal hit(damage_points : float)

@export var body : RigidBody3D
@export var body_area : Area3D
@export var alive : bool = true
@export var health_points : float = 1.0
@export var invincible_time : float = 2.0

func check_alive() -> bool :
	alive = health_points > 0
	return alive

func _on_health_area_area_entered(area: Area3D):
	if area.get_parent_node_3d().body == body: return
	#print(get_parent(), " soy al que le pican en: ", area)

func _on_ready():
	if !body : body = get_parent()
	hit.connect(func(damage_points : float):
		health_points -= damage_points
		print(body,": ouch, those ", damage_points, " really hurt, now I'm at: ", health_points, " alive: ", check_alive()))
