class_name SnappableComponent extends Node3D

signal snap()
signal grounded()
signal connected()
signal disconnected()
signal recover(new_tile : Tile)

const SNAP_FORCE : float = 35
const SNAP_Y_OFFSET : float = 0.125

## The piece this component belongs to.
@export var body : Piece
## Whether or not this component is active and other components can interact with it.
@export var active : bool = true
## The snapping area that will allow this piece to collide and snap to snappable objects.
@export var snap_area : Area3D
## The snap force which the piece will feel when snapping with a snappable object, such as a tile.
@export var snap_force : float = SNAP_FORCE
## Whether or not this piece is recoverable whenever it's a playable piece through the means of manipulation.
@export var recoverable : bool = true
## The recovery snap force. (It should always be lower than the regular snap force since the piece
## will have to travel longer distances, if maintaining a strong pull force, it will cause a mess
## along its path to the played tile).
@export var recovery_snap_force : float = SNAP_FORCE * 0.10
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
var snap_point : Vector3 :
	set(new_value) : return
	get() : 
		if snapped_to == null : return Vector3.ZERO
		return Vector3(snapped_to.global_position.x, snapped_to.global_position.y + SNAP_Y_OFFSET, snapped_to.global_position.z)
var snapped_to : Tile :
	set(new_tile): 
		snapped_to = new_tile
		if snapped_to == null :
			disconnected.emit()
			return
		snapped_to.snap.emit()
		snap.emit()
var snapping : bool :
	set(mew_value) : return
	get() : return snapped_to != null

var is_handled : bool = false
var is_grounded : bool = false :
	set(new_value) : return
	get() :
		if !body.draggable_component : return false
		return !body.draggable_component.dragged()
var is_recovering : bool = false
var attacking_snap : bool = false

func _is_tile_playable(supposed_tile : Tile) -> bool :
	# Check if the piece is currently being played,
	# and only let it snap if the tile is the current tile set in the playable component
	# or its a new playable tile judged by the playable component.
	return (!being_played || (being_played && (_playable.current_tile == supposed_tile || _playable.is_tile_playable(supposed_tile))))

func _is_tile_attackable(supposed_tile : Tile) -> bool :
	return (!being_played || (being_played && _playable.is_tile_attackable(supposed_tile) 
	&& _playable.damage_component && _playable.damage_component.active && _playable.damage_component.damage_points > 0))

func _is_tile_not_being_played(supposed_tile : Tile) -> bool :
	return (!supposed_tile.has_playable || (supposed_tile.has_playable && supposed_tile.playable_piece == _playable))


func _ready() -> void:
	if body == null: body = get_parent_node_3d()

	connected.connect( func () : 
		if snapped_to == null || !active : return
		if !attacking_snap : is_recovering = false
		snapped_to.playable_piece = _playable)
	
	grounded.connect( func () : 
		if snapped_to == null : return
		if attacking_snap && !is_recovering : 
			snapped_to.playable_piece.attacked.emit(body.damage_component)
			return
		if _playable : connected.emit())
	
	recover.connect( func ( new_tile : Tile ) : 
		if !recoverable : return
		is_recovering = true 
		snapped_to = new_tile)
	
	snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands: is_handled = true
		if parent is Tile:
			# Check if the tile is snappable and if the piece is being handled directly
			if !parent.active || !parent.snappable : return
			if is_handled :
				if ( _is_tile_playable(parent) && _is_tile_not_being_played(parent) ) :
					snapped_to = parent
				else : if _is_tile_attackable(parent) && body.damage_component : 
					snapped_to = parent
					attacking_snap = true
			else: if attacking_snap && parent == _playable.current_tile : 
				pass )
				#attacking_snap = false
	
	snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands: is_handled = false
		if parent is Tile : 
			if snapped_to == parent : stop_snapping())

func stop_snapping():
	if !active : return
	if snapped_to: 
		attacking_snap = false
		is_recovering = false
		snapped_to = null

func _round_to_decimal(num, digit : int = 2):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func is_recovering_done() -> bool :
	var final_coordinates : Vector2 = Vector2(_playable.current_tile.global_position.x, _playable.current_tile.global_position.z)
	return _round_to_decimal(final_coordinates.x) == _round_to_decimal(global_position.x) && _round_to_decimal(final_coordinates.y) == _round_to_decimal(final_coordinates.y)

func _process(_delta: float) -> void:
	if !active || body == null || !snapping || ( is_grounded && !is_recovering ) : return
	
	var draggable_component = body.draggable_component
	if draggable_component == null : return
	
	var final_snap_force : float = snap_force
	if is_recovering : 
		if is_recovering_done() : stop_snapping()
		final_snap_force = recovery_snap_force
	
	draggable_component.drag.emit(true, true, snap_point, final_snap_force, draggable_component.current_manipulator)
	
