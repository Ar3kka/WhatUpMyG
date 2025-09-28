class_name SnappableComponent extends Node3D

const SNAP_FORCE : float = 0.2
const SNAP_Y_OFFSET : float = 0.125

@export var body : Piece
@export var active : bool = true
@export var snapping : bool = false
@export var snap_area : Area3D
@export var snap_force : float = SNAP_FORCE
var snap_point : Vector3
var snapped_to : Tile :
	set(new_tile): 
		snapped_to = new_tile
		snapping = false
		snap_point = Vector3.ZERO
		if snapped_to == null : return
		snapped_to.occupier = body
		snapping = true
		snap_point = Vector3(snapped_to.global_position.x, snapped_to.global_position.y + SNAP_Y_OFFSET, snapped_to.global_position.z)

func _ready() -> void:
	if body == null: body = get_parent_node_3d()
	snap_area.area_entered.connect(func (area : Area3D):
		var tile : Tile = area.get_parent_node_3d()
		if tile && tile.active && tile.snappable : snapped_to = tile)
	snap_area.area_exited.connect(func (area : Area3D):
		var tile : Tile = area.get_parent_node_3d()
		if tile : snapped_to = null)

func stop_snapping():
	if !active : return
	if snapped_to: snapped_to = null

func _process(delta: float) -> void:
	if !active || body == null || !snapping : return
	
	var draggable_component = body.draggable_component
	if draggable_component == null : return
	
	draggable_component.drag.emit(true, true, snap_point, snap_force, draggable_component.current_manipulator)
	
