extends Node3D

signal selected(bool)

var is_selected := false

func _on_ready() -> void:
	is_selected = false
	selected.emit(false)

func _on_selected(value : bool):
	%OutlineMesh.visible = value
	is_selected = true
