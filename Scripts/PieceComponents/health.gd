class_name HealthComponent extends Node3D

signal hit(damage_points : float)

const STANDARD_MAX_HEALTH : float = 1.0

@export var active : bool = true
@export var body : Piece
@export var body_area : Area3D
@export var max_health : float = STANDARD_MAX_HEALTH
@export var health_points : float = max_health
var alive : bool = true
@export var invincible_time : float = 2.0
var invincible : bool = false

func is_alive() -> bool :
	alive = health_points > 0
	return alive

func _on_health_area_area_entered(area: Area3D):
	return
	if area.get_parent_node_3d().body == body: return
	#print(get_parent(), " soy al que le pican en: ", area)

func _on_ready():
	if body == null : body = get_parent_node_3d()
	hit.connect(func(damage_points : float):
		health_points -= damage_points
		print(body,": ouch, those ", damage_points, " really hurt, now I'm at: ", health_points, " alive: ", is_alive()))
