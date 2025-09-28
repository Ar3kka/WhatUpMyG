class_name Tile extends Node3D

@export var appearance : MeshInstance3D
var skin : StandardMaterial3D
@export var tint : Color = Color.BLACK :
	set(new_tint): 
		tint = new_tint
		set_color(tint)

@export var active : bool = true
@export var snappable : bool = true
var occupier : Piece
var _snap_area : Area3D

func _ready() -> void:
	set_color(tint)
	_snap_area = %Snap
	_snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands : 
			print("we got one of those")
			return
		if parent is SnappableComponent: occupier = parent.body)
	_snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands : 
			parent.draggable_object.snappable_component.stop_snapping()
			return
		if parent is SnappableComponent : occupier = null
		)
	

func set_color(new_tint : Color):
	if !appearance : return
	skin = StandardMaterial3D.new()
	skin.albedo_color = new_tint
	appearance.set_surface_override_material(0, skin)
