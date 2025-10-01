class_name TileGrid extends Node3D

const STANDARD_SIZE : int = 8
const STANDARD_DIRECTION : Vector2i = Vector2i(-1, -1)
const STANDARD_COLOR_PATTERN : Array[Color] = [Color.WHITE, Color.BLACK]
const STANDARD_RAISE_HEIGHT : float = 0.250

@export var active : bool = true
## The tiles that this tile grid can generate randomly throughout the map generation accounting by their
## generation chance set in each tile individually.
@export var tile_types : Array[Tile]
## Size for the matrix of tiles, where X represents the horizontal tiles and Y the vertical tiles.
@export var grid_size : Vector2i = Vector2i(STANDARD_SIZE, STANDARD_SIZE)
## When true: the gridmap size will randomize the gridsize within the range provided in the Grid Size
## vector from x to y.
@export var randomize : bool = false
## Direction for generation where X represents the horizontal direction and Y the vertical direction.
## If left on 0 it will set it to the standard direction (-1, -1)
@export var generation_direction : Vector2i = STANDARD_DIRECTION :
	set(new_direction):
		if new_direction.x == 0 : generation_direction.x = STANDARD_DIRECTION.x
		if new_direction.y == 0 : generation_direction.y = STANDARD_DIRECTION.y
		if new_direction.x > 1 : generation_direction.x = 1
		if new_direction.y > 1 : generation_direction.y = 1
		if new_direction.x < -1 : generation_direction.x = -1
		if new_direction.y < -1 : generation_direction.y = -1
## Forces the tint of the tiles to be overwritten by the color pattern entered below.
@export var force_pattern : bool = true
## The color pattern that the generation will follow with each printed tile.
## (From 0 onward)
@export var color_pattern : Array[Color] = STANDARD_COLOR_PATTERN
## Switch the color palette every other row in case the color palette matches the grid size
## causing it to merge, turn on or off this variable to change when to skip a color every other row.
@export var color_switch : bool = true
var tiles : Array[Array] 

func _ready() -> void:
	if !tile_types.size(): _reset_tyle_types()
	generate_tiles()
	get_tile_at().movable.move_up(2)

func _reset_tyle_types():
	if !active : return
	tile_types = []
	tile_types.append(Tile.new())

func get_tile_at(tile_coordinates : Vector2 = Vector2.ZERO) -> Tile:
	return tiles.get(tile_coordinates.x).get(tile_coordinates.y)
	
func generate_tiles():
	if !active : return
	
	# Check and initialize the final size of the desired grid
	var final_size : Vector2i = grid_size
	if randomize : final_size = Vector2i(randi_range(grid_size.x, grid_size.y), randi_range(grid_size.x, grid_size.y)) 
	# Initialize and calculate the color index in case needed
	# Boolean to check if the color pattern is even and switch accordingly
	var switch_pattern : bool = color_switch
	var color_index = 0
	if color_pattern.size() < 1 : force_pattern = false
	
	## Vertical Tiles
	for z in range(final_size.y):
		# Check if the color patterns are even or odd.
		if color_switch:
			switch_pattern = !switch_pattern
			if switch_pattern && color_index + 1 < color_pattern.size() : color_index += 1
			else: color_index = 0
		# Initialize the new row of vertical tiles.
		var tile_array : Array = []
		## Horizontal Tiles
		for x in range(final_size.x):
			# Instantiate the new tile and set its position and id.
			var new_tile = Tile.new().instantiate()
			new_tile.global_position = Vector3(global_position.x + x * generation_direction.x, global_position.y, global_position.z + z * generation_direction.y)
			new_tile.id = Vector2i(z, x)
			
			# Check color replacement to follow given pattern
			if force_pattern : new_tile.tint = color_pattern[color_index]
			if color_index + 1 < color_pattern.size() : color_index += 1
			else: color_index = 0
			
			# Append to array and add child to scene
			tile_array.append(new_tile)
			%Tiles.add_child(new_tile)
		# After finishing the array append it to the list of vertical arrays
		if tile_array.size() != 0: tiles.append(tile_array)
