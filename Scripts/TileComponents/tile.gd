class_name Tile extends Node3D

signal occupy(occupier : Piece)

const SCENE : PackedScene = preload("res://Scenes/Tiles/tile.tscn")
const PUSH_DOWN_MULTIPLIER : float = 0.250

## The grid this tile belongs to, in case it does.
var grid : TileGrid
## The id of the tile in the grid.
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
## If true: the tile will be pushed down the specified amount by the variable push_down_by when
## it has been occupied by a piece that is grounded (not being dragged). Only works if this tile has a
## movable component as a child node.
@export var push_down_when_occupied : bool = true
## The multiplication for the pushing (times its own size) where 1.0 is equal to its height (0.250)
@export var push_down_by : float = PUSH_DOWN_MULTIPLIER
## The movable component for this tile, this component aids moving the tile away and comunicate
## with the occupier or any stimuli that might try to move this tile. If not set, the tile will automatically
## look for a child node that is a movable component.
@export var movable : MovableComponent
var occupier : Piece :
	set(new_occupier) :
		if push_down_when_occupied:
			if new_occupier != null:
				var snappable_component: SnappableComponent = new_occupier.snappable_component
				if snappable_component : snappable_component.grounded.connect(_push_down_callable)
			else : if occupier :
				var snappable_component: SnappableComponent = occupier.snappable_component
				if snappable_component : snappable_component.grounded.disconnect(_push_down_callable)
				if !snappable_component.is_grounded && movable && _push_down: 
					movable.move_up(push_down_by)
					_push_down = false
		occupier = new_occupier
var has_playable : bool :
	set(new_value) : return
	get() : return playable_piece != null && playable_piece.active
var playable_piece : PlayableComponent
var _push_down : bool = false
var _snap_area : Area3D

func _push_down_callable():
	if !movable : return
	_push_down = true
	movable.move_down(push_down_by)

func get_movable() -> MovableComponent :
	for node in get_children() :
		if node is MovableComponent : movable = node
	return movable

func instantiate(new_active_state : bool = true, new_snappable_state : bool = true) -> Tile:
	var new_tile : Tile = SCENE.instantiate()
	new_tile.active = new_active_state
	new_tile.snappable = new_snappable_state
	return new_tile

func _ready() -> void:
	get_movable()
	appearance = %Mesh
	_snap_area = %Snap
	set_color(tint)
	
	occupy.connect(func (new_occupier : Piece) :
		occupier = new_occupier )
	
	if !_snap_area : return
	
	_snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		#if parent is Hands : return
		if parent is SnappableComponent:
			# Check if the tile already has a playable piece saved,
			# and if the entering piece is another one that is not the playable piece.
			if has_playable && playable_piece != parent._playable : return
			occupy.emit(parent.body))
	
	_snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands :
			if parent.draggable_object != occupier || occupier == null : return
			occupier.snappable_component.stop_snapping()
			return
		if parent is SnappableComponent : 
			if occupier == null : return
			occupier.snappable_component.stop_snapping()
			occupy.emit(null))

func set_color(new_tint : Color):
	if !appearance : return
	skin = StandardMaterial3D.new()
	skin.albedo_color = new_tint
	appearance.set_surface_override_material(0, skin)
