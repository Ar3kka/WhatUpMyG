class_name Tile extends Node3D

signal translate(translation_vector : Vector3)

signal raise(height : float)

const SCENE : PackedScene = preload("res://Scenes/Tiles/tile.tscn")
const STANDARD_UP_DOWN_DISTANCE : float = 0.250
const STANDARD_LEFT_RIGHT_DISTANCE : float = 1.0
const STANDARD_TRANSLATION_STRENGTH : float = 0.05

var id : Vector2i = Vector2i.ZERO
## The meshinstance3D set for this tile.
@export var appearance : MeshInstance3D
var skin : StandardMaterial3D
## The color for the tile surface material.
@export var tint : Color = Color.WHITE :
	set(new_tint): 
		tint = new_tint
		set_color(tint)
## If not active it will not work in any way.
@export var active : bool = true :
	set(new_active_state):
		active = new_active_state
		visible = new_active_state
## Whether or not this tile can have a piece snapped to its snap area.
@export var snappable : bool = true
## Whether or not this tile is movable through its move and translation functions
@export var movable : bool = true
var occupier : Piece
var _snap_area : Area3D

var _translation_vector : Vector3 = Vector3.ZERO :
	set(new_vector) :
		if new_vector == Vector3.ZERO :
			_translation_vector = new_vector
			return
		new_vector.x += global_position.x
		new_vector.y += global_position.y
		new_vector.z += global_position.z
		_translation_vector = new_vector

func instantiate(new_active_state : bool = true, new_snappable_state : bool = true) -> Tile:
	var new_tile : Tile = SCENE.instantiate()
	new_tile.active = new_active_state
	new_tile.snappable = new_snappable_state
	return new_tile

func _ready() -> void:
	translate.connect(translation)
	appearance = %Mesh
	_snap_area = %Snap
	set_color(tint)
	
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

func translation(translation_direction : Vector3 = Vector3.ZERO):
	_translation_vector = translation_direction
	
func move_up(times : int = 1): _translation_vector = Vector3(0, STANDARD_UP_DOWN_DISTANCE * times, 0)

func move_down(times : int = 1): _translation_vector = Vector3(0, -STANDARD_UP_DOWN_DISTANCE * times, 0)

func move_left(times : int = 1): _translation_vector = Vector3(-STANDARD_LEFT_RIGHT_DISTANCE * times, 0, 0)

func move_right(times : int = 1): _translation_vector = Vector3(STANDARD_LEFT_RIGHT_DISTANCE * times, 0, 0)

func move_forth(times : int = 1): _translation_vector = Vector3(0, 0, STANDARD_LEFT_RIGHT_DISTANCE * times)

func move_back(times : int = 1): _translation_vector = Vector3(0, 0, -STANDARD_LEFT_RIGHT_DISTANCE * times)

func stop_translation():
	_translation_vector = Vector3.ZERO

func is_translating() -> bool : return _translation_vector != Vector3.ZERO

func _has_translation_reached_goal() -> bool :
	return _round_to_decimal(global_position) == _round_to_decimal(_translation_vector)

func _round_to_decimal(num, digit : int = 2):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _process(delta: float) -> void:
	if !active || !movable: return
	
	if _has_translation_reached_goal() : stop_translation()
	
	if !is_translating() : return
	
	global_position = lerp(global_position, _translation_vector, STANDARD_TRANSLATION_STRENGTH)
