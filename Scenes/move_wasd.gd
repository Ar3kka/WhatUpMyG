extends Node3D

@export var camera : Camera3D
const SPEED = 7.5

func _process(delta):
	var input_dir := Input.get_vector("Stride Left", "Stride Right", "Forward", "Back")
	if !input_dir: pass
	if input_dir == Vector2.UP || Vector2.DOWN:
		camera.global_position.z += input_dir.y * SPEED * delta
	if input_dir == Vector2.RIGHT || Vector2.LEFT:
		camera.global_position.x += input_dir.x * SPEED * delta
