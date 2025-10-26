class_name Tile extends Node3D

signal occupied()
signal unoccupied()
signal snap()
signal highlighted()
signal unhighlighted()
signal connected()
signal disconnected()
signal pressed()
signal unpressed()
signal instantiated()

const SCENE : PackedScene = preload("res://Scenes/Tiles/tile.tscn")
const PUSH_STANDARD_MULTIPLIER : float = 0.250
const PUSH_DOWN_MULTIPLIER : float = PUSH_STANDARD_MULTIPLIER
const RAISE_UP_MULTIPLIER : float = PUSH_STANDARD_MULTIPLIER
const HIGHLIGHT_STRENGTH : float = 0.5

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
@export var accept_non_playables : bool = false
var _snap_area : Area3D

@export_category("Reaction Settings")
## The movable component for this tile, this component aids moving the tile away and comunicate
## with the occupier or any stimuli that might try to move this tile. If not set, the tile will automatically
## look for a child node that is a movable component.
@export var movable : MovableComponent
@export_group("Connect reaction")
## When true, the tile will be pushed down the specified amount by the variable push_down_by when
## it has been occupied by a piece that is grounded (not being dragged). Only works if this tile has a
## movable component as a child node.
@export var pressable : bool = true
## The multiplication for the pushing (times its own size) where 1.0 is equal to its height (0.250)
@export var press_down_by : float = PUSH_DOWN_MULTIPLIER
var is_pressing : bool
@export_group("Playable reaction")
## When true, the tile will be pushed up the specified amount by the variable raise_up_by when
## it its been deemed playable by the currently dragged playable piece (not grounded). Only works if this tile has a
## movable component as a child node.
@export var highlightable : bool = true
## When true, the highlight color will be the one set before it's been locked, and will not be altered until lock color is false.
@export var lock_color : bool = false
## The color that the tile will change to whenever it's being highlighted.
## The default color is the same as for the tint.
@export var highlight_color : Color = tint:
	set(new_value) :
		if lock_color : return
		highlight_color = new_value 
@export var highlight_strength : float = HIGHLIGHT_STRENGTH
## The multiplication for the highlight push (times its own size) where 1.0 is equal to its height (0.250)
@export var raise_up_by : float = RAISE_UP_MULTIPLIER
var is_highlighting : bool = false
#var highlight_press : bool = false

var occupier : Piece
var has_playable : bool :
	set(new_value) : return
	get() : return playable_piece != null && playable_piece.active
var playable_piece : PlayableComponent :
	set(new_value) :
		if !is_playable : return
		playable_piece = new_value
		if grid == null : return 
		if playable_piece == null : grid.played_tiles -= 2 ; return
		grid.played_tiles += 1
var current_team : TeamComponent :
	set(new_value) : return
	get() :
		if !has_playable : return
		return playable_piece.body.team_component
	
func instantiate(new_active_state : bool = true, new_snappable_state : bool = true) -> Tile:
	var new_tile : Tile = SCENE.instantiate()
	new_tile.active = new_active_state
	new_tile.snappable = new_snappable_state
	new_tile.instantiated.emit()
	return new_tile

func highlight(color_highlight : bool, new_color : Color, new_highlight_strength : float = highlight_strength) :
	if !highlightable : return
	is_highlighting = true
	if color_highlight :
		highlight_color = new_color
		highlight_strength = new_highlight_strength
		set_color(lerp(tint, highlight_color, highlight_strength))
	highlighted.emit()
	if playable_piece : return
	raise_up()

func unhighlight() :
	if playable_piece == null : reset_position()
	is_highlighting = false
	highlight_color = tint
	set_color(tint)
	unhighlighted.emit()

func occupy(new_occupier : Piece) :
	if new_occupier == null : return unocuppy()
	if ( is_highlighting && new_occupier != occupier &&
	new_occupier.snappable_component && new_occupier.snappable_component.is_handled ) : reset_position()
	occupier = new_occupier
	occupied.emit()

func unocuppy() :
	if is_highlighting : raise_up()
	else : if !has_playable : reset_position()
	occupier = null 
	unoccupied.emit()

func press() :
	if !pressable : return
	is_pressing = true
	press_down()
	pressed.emit()

func unpress() :
	if occupier != null || has_playable : return
	reset_position()
	is_pressing = false
	unpressed.emit()

func raise_up():
	if movable == null || !is_highlighting || has_playable : return
	movable.change_to_state(1)

func press_down():
	if movable == null || !pressable || !is_pressing : return
	movable.change_to_state(2)

func reset_position() :
	if movable == null || ( has_playable && !playable_piece.is_deceased ) : return
	movable.reset.emit(true)

func connect_to(new_playable_piece : PlayableComponent):
	press()
	playable_piece = new_playable_piece
	connected.emit()

func disconnect_playable():
	playable_piece = null
	unpress()
	disconnected.emit()

func set_movable() -> MovableComponent :
	for node in get_children() :
		if node is MovableComponent : movable = node
	movable.vertical_multiplier = Vector2(raise_up_by, press_down_by)
	movable.reset_vector_states()
	return movable

func set_color(new_tint : Color):
	if appearance == null : return
	skin = StandardMaterial3D.new()
	skin.albedo_color = new_tint
	appearance.set_surface_override_material(0, skin)

func _is_different_playable_and_not_attacking(snappable_comp : SnappableComponent) -> bool :
	return has_playable && playable_piece != snappable_comp._playable && !snappable_comp.attacking_snap

func _is_playable_deceased(snappable_comp : SnappableComponent) -> bool :
	return snappable_comp._playable && snappable_comp._playable.is_deceased

func _ready() -> void:
	set_movable()
	appearance = %Mesh
	_snap_area = %Snap
	set_color(tint)
	
	if _snap_area == null : return
	
	_snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is SnappableComponent:
			# Check if the tile already has a playable piece saved,
			# and if the entering piece is another one that is not the playable piece.
			if _is_different_playable_and_not_attacking(parent) || _is_playable_deceased(parent) : return
			occupy(parent.body) )
	
	_snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands :
			if parent.draggable_object != occupier || occupier == null : return
			occupier.snappable_component.stop_snapping()
			unocuppy()
			return
		if parent is SnappableComponent : 
			if occupier == null : return
			if parent.snapped_to == self : occupier.snappable_component.stop_snapping()
			if occupier.snappable_component != parent || ( has_playable && playable_piece.snappable_component == occupier.snappable_component ) : return
			unocuppy() )
