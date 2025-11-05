class_name SnappableComponent extends Node3D

signal snap()
signal grounded()
signal connected()
signal disconnected()
signal recover(new_tile : Tile)
signal attack_recover()
signal auto_recover(is_hit : bool)

const AUTO_RECOVERY_TIME : float = 4.0
const RECOVERY_SNAP_FORCE : float = 3.5
const ATTACK_SNAP_FORCE : float = 12.5
const KEYBOARD_MOVEMENT_SNAP_FORCE : float = 20.0
const SNAP_FORCE : float = 35
const SNAP_Y_OFFSET : float = 0.125

var global := GeneralKnowledge.new()

## The piece this component belongs to.
@export var body : Piece
## Whether or not this component is active and other components can interact with it.
@export var active : bool = true
## The snapping area that will allow this piece to collide and snap to snappable objects.
@export var snap_area : Area3D
## The snap force which the piece will feel when snapping with a snappable object, such as a tile.
@export var snap_force : float = SNAP_FORCE
## Whether or not this piece is recoverable whenever it's a playable piece through the means of manipulation.
@export_group("Recovery Settings")
@export var recoverable : bool = true
@export var displacement_recovery : bool = true
@export var hit_recovery : bool = true
@export var recovery_time : float = AUTO_RECOVERY_TIME :
	set(new_recovery_time) : _current_timer.wait_time = new_recovery_time
## The recovery snap force. (It should always be lower than the regular snap force since the piece
## will have to travel longer distances, if maintaining a strong pull force, it will cause a mess
## along its path to the played tile).
@export var recovery_snap_force : float = RECOVERY_SNAP_FORCE
@export var attack_recovery_snap_force : float = ATTACK_SNAP_FORCE
@export var keyboard_movement_snap_force : float = KEYBOARD_MOVEMENT_SNAP_FORCE
var just_in_recovery : bool = false
var _draggable : DraggableComponent :
	get() :
		if body == null : return
		return body.draggable_component 
var _playable : PlayableComponent :
	get() :
		if body == null : return
		return body.playable_component
var being_played : bool = false :
	get() :
		if _playable == null : return false
		return _playable.being_played
var played_tile : Tile :
	get() : 
		if !being_played : return
		return _playable.current_tile
var snap_point : Vector3 :
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
var _current_timer : Timer = Timer.new()
var _hit_reset : bool = false
var keyboard_recovery : bool = false

func _is_tile_playable(supposed_tile : Tile) -> bool :
	# Check if the piece is currently being played,
	# and only let it snap if the tile is the current tile set in the playable component
	# or its a new playable tile judged by the playable component.
	return (!being_played || (being_played && !_playable.is_deceased && (_playable.current_tile == supposed_tile || _playable.is_tile_playable(supposed_tile))))

func _is_tile_attackable(supposed_tile : Tile) -> bool :
	return ( being_played && _playable.is_tile_attackable(supposed_tile) 
	&& _playable.damage_component && _playable.damage_component.active && _playable.damage_component.damage_points > 0 )

func _is_tile_not_being_played(supposed_tile : Tile) -> bool :
	return (!supposed_tile.has_playable || (supposed_tile.has_playable && supposed_tile.playable_piece == _playable))

func snap_to(new_tile : Tile, is_attacking : bool = false) :
	snapped_to = new_tile
	if !is_attacking : return
	attacking_snap = true
	snapped_to.occupy(body)

func _ready() -> void:
	if body == null: body = get_parent_node_3d()
	
	_current_timer.one_shot = true
	_current_timer.wait_time = recovery_time
	_current_timer.timeout.connect(func () : 
		if _playable != null : 
			just_in_recovery = false
			_hit_reset = true
			_playable.reset_to_playable_position() )
	add_child(_current_timer)

	connected.connect( func () : 
		if snapped_to == null || !active : return
		if !attacking_snap : is_recovering = false
		else : attacking_snap = false
		if _playable && _playable.current_tile : _playable.current_tile.unocuppy()
		snapped_to.playable_piece = _playable )
	
	grounded.connect( func () :
		if is_recovering && !keyboard_recovery : stop_snapping() ; return
		if snapped_to == null : return
		var is_attackable : bool = _is_tile_attackable(snapped_to)
		if _playable && ( _is_tile_playable(snapped_to) || is_attackable ) : 
			if is_attackable : attack_recover.emit() 
			connected.emit() ; return
		if keyboard_recovery : stop_snapping(true) )
	
	attack_recover.connect( func () : 
		if snapped_to == null || !active || !recoverable : return
		if ( attacking_snap && !is_recovering ) || keyboard_recovery : 
			snapped_to.playable_piece.attacked.emit(body.damage_component) )
	
	auto_recover.connect( func (is_hit : bool = false) :
		if !recoverable || (is_hit && !hit_recovery) || !displacement_recovery : return
		just_in_recovery = true
		_current_timer.start() )
	
	recover.connect( func ( new_tile : Tile ) : 
		if !recoverable : return
		is_recovering = true 
		snap_to(new_tile) )
	
	snap_area.area_entered.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands: is_handled = true
		if parent is Tile:
			# Check if the tile is snappable and if the piece is being handled directly
			if !parent.active || !parent.snappable : return
			if is_handled && _playable && !_playable.is_deceased:
				if _is_tile_playable(parent) && _is_tile_not_being_played(parent) : snap_to(parent)
				else : if _is_tile_attackable(parent) && body.damage_component && body.draggable_component :
					snap_to(parent, true) )
	
	snap_area.area_exited.connect(func (area : Area3D):
		var parent = area.get_parent_node_3d()
		if parent is Hands: is_handled = false
		if parent is Tile : 
			if parent == played_tile && is_grounded && displacement_recovery : auto_recover.emit() )
			#if snapped_to == parent : stop_snapping() )

func stop_snapping(ignore_snapping_tile : bool = false):
	if !active || snapped_to == null : return
	_current_timer.stop()
	just_in_recovery = false
	_hit_reset = false
	attacking_snap = false
	keyboard_recovery = false
	is_recovering = false
	if !ignore_snapping_tile : snapped_to = null

func stop_entirely(restart_recovery : bool = false):
	if !_draggable : return
	if restart_recovery && _hit_reset : _current_timer.start() 
	_draggable.stop_dragging()
	stop_snapping()

func is_recovering_done() -> bool :
	var final_coordinates : Vector2 = Vector2(_playable.current_tile.global_position.x, _playable.current_tile.global_position.z)
	return ( global.round_to_decimal(final_coordinates.x) == global.round_to_decimal(global_position.x)
	 && global.round_to_decimal(final_coordinates.y) == global.round_to_decimal(global_position.z) )

func cannot_recover() -> bool :
	return is_tile_occupied() && played_tile.occupier.snappable_component && !played_tile.occupier.snappable_component.is_grounded

func is_tile_occupied() -> bool :
	return played_tile && played_tile.occupier != null && played_tile.occupier != body

func _process(_delta: float) -> void:
	if !active || body == null : return
	
	if just_in_recovery && cannot_recover()  : _current_timer.start()
	
	if !snapping || ( is_grounded && !is_recovering ) : return
	
	if _playable != null && _playable.is_deceased : stop_entirely() ; return
	
	if _draggable == null : return
	var final_snap_force : float = snap_force
	
	if is_recovering :
		if attacking_snap && is_recovering_done() : stop_entirely() ; return
		if _hit_reset && ( cannot_recover() || is_recovering_done() ) : stop_entirely(true) ; return
		final_snap_force = recovery_snap_force
		if attacking_snap : final_snap_force = attack_recovery_snap_force
		if keyboard_recovery : final_snap_force = keyboard_movement_snap_force
	
	_draggable.drag.emit(true, true, snap_point, final_snap_force, _draggable.current_manipulator)
