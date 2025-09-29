class_name Tile extends Node3D

const SCENE: PackedScene = preload("res://Scenes/Tiles/tile.tscn")

@export var appearance : MeshInstance3D
var skin : StandardMaterial3D
@export var tint : Color = Color.WHITE :
	set(new_tint): 
		tint = new_tint
		set_color(tint)

@export var active : bool = true :
	set(new_active_state):
		active = new_active_state
		visible = new_active_state
		 
@export var snappable : bool = true
var occupier : Piece
var _snap_area : Area3D
var id : Vector2i = Vector2i.ZERO 

func instantiate(new_active_state : bool = true, new_snappable_state : bool = true) -> Tile:
	var new_tile : Tile = SCENE.instantiate()
	new_tile.active = new_active_state
	new_tile.snappable = new_snappable_state
	return new_tile

func _ready() -> void:
	set_color(tint)
	appearance = %Mesh
	_snap_area = %Snap
	if !_snap_area : return
	_snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		#if parent is Hands : return
		if parent is SnappableComponent: 
			occupier = parent.body)
	_snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands :
			if parent.draggable_object != occupier || !occupier : return
			occupier.snappable_component.stop_snapping()
			return
		if parent is SnappableComponent : 
			if occupier == null: return
			occupier.snappable_component.stop_snapping()
			occupier = null)

func set_color(new_tint : Color):
	if !appearance : return
	skin = StandardMaterial3D.new()
	skin.albedo_color = new_tint
	appearance.set_surface_override_material(0, skin)
