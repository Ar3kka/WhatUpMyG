class_name DamageComponent extends Node3D

@export var body : RigidBody3D
@export var damage_area : Area3D
@export var active : bool = true
@export var damage_points : float = 1.0
@export var cooldown_time : float = 2.0

func hit(health_component : HealthComponent):
	health_component.hit.emit(damage_points)
	print(body, ": toma mis: ", damage_points, " pinchi burroide menso: ", health_component.body)

func _on_damage_area_area_entered(area: Area3D):
	var health_component := area.get_parent_node_3d()
	if health_component.body == body: return
	hit(health_component)
	#print(get_parent(), ": este es al que se supone que le puedo pegar: ", health_component.body)

func _on_ready():
	if body == null : body = get_parent_node_3d()
