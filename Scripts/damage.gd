extends Node3D
class_name damage_component

@export var body : RigidBody3D
@export var damage_area : Area3D
@export var active := true
@export var damage_points := 1.0
@export var cooldown_time := 2.0

func _hit(health_comp : health_component):
	health_comp.hit.emit(damage_points)
	print(body, ": toma mis: ", damage_points, " pinchi burroide menso: ", health_comp.body)

func _on_damage_area_area_entered(area: Area3D):
	var health_comp := area.get_parent_node_3d()
	if health_comp.body == body: return
	_hit(health_comp)
	#print(get_parent(), ": este es al que se supone que le puedo pegar: ", health_component.body)

func _on_ready():
	if !body : body = get_parent()
