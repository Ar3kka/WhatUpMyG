class_name TileGrid extends Node3D

signal generate()

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
var last_row : Array :
	set(new_value) : return
	get() : return tiles.get(tiles.size() - 1)
var last_tile : Tile :
	set (new_value) : return
	get() : return last_row[last_row.size() - 1]

func _ready() -> void:
	if !tile_types.size(): _reset_tyle_types()
	generate_tiles()
	print(get_tile_at(Vector2i(8, 0)))
	#add_row()
	#read_grid()
	#print(get_tiles_from(Vector2i.ZERO, Vector2i(1, 1), 10))
	#print(get_specific_tile_from(Vector2i(1, 1), Vector2i(1, 2)))
	#print(get_tiles_following_pattern(Vector2i(2, 3), Vector2i(2, -1), true))

func add_row():
	
	var switch_pattern : bool = color_switch
	var color_index = 0
	if color_pattern.size() < 1 : force_pattern = false
	
	if color_switch:
		switch_pattern = !switch_pattern
		if switch_pattern && color_index + 1 < color_pattern.size() : color_index += 1
		else: color_index = 0
	
	# Initialize the new row of vertical tiles.
	var tile_array : Array = []
	
	for index in range(grid_size.x):
	# Instantiate the new tile and set its position and id.
		var new_tile = Tile.new().instantiate()
		new_tile.global_position = Vector3(last_row[0].global_position.x - index, last_row[0].global_position.y, last_row[0].global_position.z - 1)
		new_tile.id = Vector2i(grid_size.y, index)
		new_tile.grid = self
		# Check color replacement to follow given pattern
		if force_pattern : new_tile.tint = color_pattern[color_index]
		if color_index + 1 < color_pattern.size() : color_index += 1
		else: color_index = 0
		# Append to array and add child to scene
		tile_array.append(new_tile)
		%Tiles.add_child(new_tile)
	
	if tile_array.size() != 0: tiles.append(tile_array)

func read_grid():
	if tiles == null || tiles.size() < 1 : return
	var coordinates : Vector2i = Vector2i.ZERO
	for row in tiles:
		for tile in row:
			tile.id = coordinates
			coordinates.y += 1
	coordinates.x += 1

func _reset_tyle_types():
	if !active : return
	tile_types = []
	tile_types.append(Tile.new().instantiate())

## Get tiles in set direction within the grid from an specified coordinate location.
## and returns the specified number of tiles in that direction set by the reach variable.
## the direction vector works as follows: 
## 
## If a direction is not given, a single tile will be returned as part of the array, ignoring the reach given.
func get_tiles_from(origin_coordinates : Vector2i = Vector2i.ZERO, direction : Vector2i = Vector2i(1, 0), reach : int = 1) -> Array[Tile] :
	var result_tiles : Array[Tile]
	if direction == Vector2i.ZERO : 
		tiles.append(get_tile_at(origin_coordinates))
		return result_tiles
	if origin_coordinates.x > grid_size.y : origin_coordinates.x = grid_size.x
	if origin_coordinates.y > grid_size.x : origin_coordinates.y = grid_size.y
	var final_reach = reach
	if final_reach > tiles.size() : final_reach = tiles.size()
	for id in range(final_reach) :
		var final_id = id + 1
		var final_coordinates = origin_coordinates
		if direction.x > 0 : final_coordinates.x += final_id # front
		else : if direction.x < 0 : final_coordinates.x -= final_id # rear
		if direction.y > 0 : final_coordinates.y += final_id # left
		else: if direction.y < 0 : final_coordinates.y -= final_id # right
		var tile : Tile = get_tile_at(final_coordinates)
		if tile != null : result_tiles.append(tile)
	return result_tiles

## Get tiles following an especific direction pattern provided from an origin point,
## rounds of patterns can be set, if mirror is true the rounds will be duplicated and 
## the algorithm will be adapted to scan all possible combinations around the origin tile using the given rounds.
## if pattern is not given, a single tile will be returned from the provided origin coordinates.
func get_tiles_following_pattern(origin_coordinates : Vector2i = Vector2i.ZERO, pattern : Vector2i = Vector2i(1, 0), mirror : bool = true, rounds : int = 4) :
		var result_tiles : Array[Tile]
		if pattern == Vector2i.ZERO :
			result_tiles.append(get_tile_at(origin_coordinates))
			return result_tiles
		var final_pattern : Vector2i = pattern
		if mirror : rounds *= 2
		for round in range(rounds):
			var tile : Tile = get_specific_tile_from(origin_coordinates, final_pattern)
			## Horse algorithm example: 
			# swap, y *= -1 gets negative
			#(2, -1) (2, 1) horse front
			# swap, y *= -1 gets negative
			#(-1, -2) (1, -2) horse right
			# swap, y *= -1 gets positive
			#(-2, 1) (-2, -1) horse rear
			# swap, y *= -1 gets positive
			#(1, 2) (-1, 2) horse left
			# swap, y *= -1 gets negative
			final_pattern = Vector2i(final_pattern.y, final_pattern.x)
			if !mirror || (mirror && round != (rounds / 2) - 1): final_pattern.y *= -1
			result_tiles.append(tile)
		return result_tiles

## Get a single tile following an specific direction starting from the origin coordinates provided where direction is:
## Vector2i(up(1) or down(-1), left (1) or right (-1)).
func get_specific_tile_from(origin_coordinates : Vector2i = Vector2i.ZERO, direction : Vector2i = Vector2i(1, 0)):
	var final_coordinates = Vector2i(origin_coordinates.x + direction.x, origin_coordinates.y + direction.y)
	var result_tile : Tile = get_tile_at(final_coordinates)
	return result_tile

## Get the tile in the coordinates given, returns null if coordinates aren't following
## the current grid size parameters.
func get_tile_at(tile_coordinates : Vector2i = Vector2i.ZERO) -> Tile:
	var supposed_horizontal = tiles.get(tile_coordinates.x)
	if supposed_horizontal == null : return
	return supposed_horizontal.get(tile_coordinates.y)
	
func generate_tiles():
	if !active : return
	generate.emit()
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
			new_tile.grid = self
			# Check color replacement to follow given pattern
			if force_pattern : new_tile.tint = color_pattern[color_index]
			if color_index + 1 < color_pattern.size() : color_index += 1
			else: color_index = 0
			# Append to array and add child to scene
			tile_array.append(new_tile)
			%Tiles.add_child(new_tile)
		# After finishing the array append it to the list of vertical arrays
		if tile_array.size() != 0: tiles.append(tile_array)
