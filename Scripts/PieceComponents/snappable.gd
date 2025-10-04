class_name SnappableComponent extends Node3D

signal snap()
signal grounded()
signal connected()
signal disconnected()

const SNAP_FORCE : float = 0.3
const SNAP_Y_OFFSET : float = 0.125

@export var body : Piece
@export var active : bool = true
@export var snapping : bool = false
@export var snap_area : Area3D
@export var snap_force : float = SNAP_FORCE
var _playable : PlayableComponent = null :
	set(new_value) : return
	get() :
		if body == null : return
		return body.playable_component
var being_played : bool = false :
	set(new_value) : return
	get() :
		if _playable == null : return false
		return _playable.being_played
var snap_point : Vector3 
var snapped_to : Tile :
	set(new_tile): 
		snapped_to = new_tile
		snapping = false
		snap_point = Vector3.ZERO
		if snapped_to == null :
			disconnected.emit()
			return
		snap.emit()
		snapping = true
		snap_point = Vector3(snapped_to.global_position.x, snapped_to.global_position.y + SNAP_Y_OFFSET, snapped_to.global_position.z)
var is_handled : bool = false
var is_grounded : bool = false :
	set(new_value) : return
	get() :
		if !body.draggable_component : return false
		return !body.draggable_component.dragged()

func _is_tile_playable(supposed_tile : Tile) -> bool :
	# Check if the piece is currently being played,
	# and only let it snap if the tile is the current tile set in the playable component
	# or its a new playable tile judged by the playable component.
	return (!being_played || (being_played && (_playable.current_tile == supposed_tile || _playable.is_tile_playable(supposed_tile))))

func _is_tile_not_being_played(supposed_tile : Tile) -> bool :
	return (!supposed_tile.has_playable || (supposed_tile.has_playable && supposed_tile.playable_piece == _playable))

func _ready() -> void:
	if body == null: body = get_parent_node_3d()
	
	disconnected.connect(func () : 
		if snapped_to == null || !active : return
		snapped_to.playable_piece = null)
	connected.connect( func () : 
		if snapped_to == null || !active : return
		snapped_to.playable_piece = _playable)
	grounded.connect( func () : if _playable && snapped_to != null : connected.emit())
	
	snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands: is_handled = true
		if parent is Tile:
			# Check if the tile is snappable and if the piece is being handled directly
			if ( parent.active && parent.snappable && is_handled
			&& _is_tile_playable(parent)
			&& _is_tile_not_being_played(parent)) :
				snapped_to = parent )
	
	snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands: is_handled = false
		if parent is Tile : 
			if snapped_to == parent : stop_snapping())

func stop_snapping():
	if !active : return
	if snapped_to: snapped_to = null

func _process(delta: float) -> void:
	if !active || body == null || !snapping || is_grounded : return
	
	var draggable_component = body.draggable_component
	if draggable_component == null : return
	
	draggable_component.drag.emit(true, true, snap_point, snap_force, draggable_component.current_manipulator)
	
