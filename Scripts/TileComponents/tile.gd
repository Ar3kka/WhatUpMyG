class_name Tile extends Node3D

signal occupy(occupier : Piece)
signal highlight(new_highlight_value : bool)
signal connected()
signal disconnected()
signal press(new_press_value : bool)

const SCENE : PackedScene = preload("res://Scenes/Tiles/tile.tscn")
const PUSH_STANDARD_MULTIPLIER : float = 0.250
const PUSH_DOWN_MULTIPLIER : float = PUSH_STANDARD_MULTIPLIER
const RAISE_UP_MULTIPLIER : float = PUSH_STANDARD_MULTIPLIER

@export_category("General Tile Settings")
## The grid this tile belongs to, in case it does.
var grid : TileGrid
## The id of the tile in the grid.
var id : Vector2i = Vector2i.ZERO
## The meshinstance3D set for this tile.
## If not active it will not work in any way.
@export var active : bool = true :
	set(new_active_state):
		active = new_active_state
		visible = new_active_state
@export var appearance : MeshInstance3D
var skin : StandardMaterial3D
## The color for the tile surface material.
@export var tint : Color = Color.WHITE :
	set(new_tint): 
		tint = new_tint
		set_color(tint)
## Whether or not this tile can have a piece snapped to its snap area.
@export var snappable : bool = true
## Wether or not this tile is a playable tile.
@export var is_playable : bool = true
var _snap_area : Area3D

@export_category("Reaction Settings")
## The movable component for this tile, this component aids moving the tile away and comunicate
## with the occupier or any stimuli that might try to move this tile. If not set, the tile will automatically
## look for a child node that is a movable component.
@export var movable : MovableComponent
@export_group("Being played reaction")
## When true, the tile will be pushed down the specified amount by the variable push_down_by when
## it has been occupied by a piece that is grounded (not being dragged). Only works if this tile has a
## movable component as a child node.
@export var pressable : bool = true
## The multiplication for the pushing (times its own size) where 1.0 is equal to its height (0.250)
@export var press_down_by : float = PUSH_DOWN_MULTIPLIER
var _pressing_down : bool = false
@export_group("Playable reaction")
## When true, the tile will be pushed up the specified amount by the variable raise_up_by when
## it its been deemed playable by the currently dragged playable piece (not grounded). Only works if this tile has a
## movable component as a child node.
@export var highlightable : bool = true
## The multiplication for the highlight push (times its own size) where 1.0 is equal to its height (0.250)
@export var raise_up_by : float = RAISE_UP_MULTIPLIER
var _highlight_push : bool = false

var occupier : Piece
var has_playable : bool :
	set(new_value) : return
	get() : return playable_piece != null && playable_piece.active
var playable_piece : PlayableComponent :
	set(new_value) :
		if !is_playable : return
		playable_piece = new_value

func raise_up():
	if !movable || !highlightable || !_highlight_push: return
	movable.move_up(raise_up_by)

func press_down():
	if !movable || !pressable || !_pressing_down: return
	movable.move_down(press_down_by)

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
	highlight.connect(func (new_highlight_value : bool) :
		if new_highlight_value == false && _highlight_push: 
			movable.move_down(raise_up_by)
			_highlight_push = new_highlight_value
			return
		if _highlight_push && new_highlight_value : return
		_highlight_push = new_highlight_value
		raise_up())
	press.connect(func (new_press_value : bool) :
		if new_press_value == false && _pressing_down: 
			movable.move_up(press_down_by)
			_pressing_down = new_press_value
			return
		if _pressing_down && new_press_value : return
		_pressing_down = new_press_value
		press_down())
	connected.connect(func () : press.emit(true))
	disconnected.connect(func () : press.emit(false))
	
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
