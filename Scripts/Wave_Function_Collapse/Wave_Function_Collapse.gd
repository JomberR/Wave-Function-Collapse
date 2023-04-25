#The overall manager. Responsible for populating the tilemap with cells, and calling them.
#It is also responsible for managing tile resources within the cells.
extends Node2D
class_name Wave_Function_Collapse

@export var width: int = 25
@export var height: int = 15

@export var tileMap: TileMap
@export var wave_cell: PackedScene
@export var possible_tiles_resources: Array[Wave_Tile] = []

@export var placement_delay: float = .01
@export var tiles_to_place: int = 1

var _map_size: int
var _wave_cells: Dictionary
var _delay: float
var _is_generating: bool = false
var _propagationQueue: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_delay = placement_delay
	_map_size = width * height
	
func generate_map():
	_map_size = width * height
	
	tileMap.clear()
	_wave_cells.clear()
	_propagationQueue.clear()
	_reset_tile_count()
	_set_tile_map_size()
	
	_populate_cells(wave_cell)
	_collapse_random_cell()
	_gradual_generate()
	
	#_instant_generate()

func set_map_size(value: int, dimension: String):
	if (dimension == "x"):
		width = value
		
	if (dimension == "y"):
		height = value

#func _process(delta):
#	pass
		

func _gradual_generate():
	while (_wave_cells.size() > 0):
		for i in tiles_to_place:
			_processPropagations()
			_collapse_cell()
		await get_tree().create_timer(_delay).timeout

func _instant_generate():
	for i in _wave_cells.size():
		_collapse_cell()
	_is_generating = false

func _reset_tile_count():
	for tile_resource in possible_tiles_resources:
		tile_resource.tiles_placed = 0
		
func _set_tile_map_size():
	for tile_resource in possible_tiles_resources:
		tile_resource.map_size = _map_size

func _populate_cells(cell):
	for x in width:
		for y in height:
			_create_cell(Vector2i(x,y), cell)

func _create_cell(location: Vector2i, cell: PackedScene):
	var node: Wave_Cell = cell.instantiate()
	node.updated_tiles.connect(_queuePropagation)
	node.placed_tile.connect(_increment_tile_count)
	node.init(location, tileMap, possible_tiles_resources)
	
	#We're formatting it like this because this is what a vector2int looks like when casted to a string.
	var key_value = "(" + str(location.x) + ", " + str(location.y) + ")"
	_wave_cells[key_value] = node
	
func _collapse_cell():
	if(_wave_cells.size() <= 0):
		return
	var cell = _find_lowest_entropy()
	
	#Remove the cell from the list so we don't call it again.
	_wave_cells.erase(_wave_cells.find_key(cell))
	
	cell.collapse()
	
func _cell_sort(a, b):
	var entropy_a = a.possible_tile_nodes.size()
	var entropy_b = b.possible_tile_nodes.size()
	
	if(entropy_a < entropy_b):
		return true
	else:
		return false
		
func _find_lowest_entropy() -> Wave_Cell:
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	var rand_int = random.randi_range(0, _wave_cells.size() - 1)
	
	var lowest_cell: Wave_Cell = _wave_cells.values()[rand_int]
	
	for cell in _wave_cells.values():
		if (lowest_cell.possible_tile_nodes.size() > cell.possible_tile_nodes.size()):
			lowest_cell = cell
			
	return lowest_cell

func _collapse_random_cell():
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	if(_wave_cells.size() <= 0):
		return
	
	var rand_int = random.randi_range(0, _wave_cells.size() - 1)
	
	_wave_cells.values()[rand_int].collapse()
	_wave_cells.erase(_wave_cells.keys()[rand_int])

func _propagate(superposition, location):
	#Remember a POSITIVE y value is DOWN
	#Key values are stored as a stringified vector.
	var northwest = str(location + Vector2i(-1, -1))
	var north = str(location + Vector2i(0, -1))
	var northeast = str(location + Vector2i(1, -1))
	var east = str(location + Vector2i(1, 0))
	var southeast = str(location + Vector2i(1, 1))
	var south = str(location + Vector2i(0, 1))
	var southwest = str(location + Vector2i(-1, 1))
	var west = str(location + Vector2i(-1, 0))
	
	if(_wave_cells.has(northwest)):
		_wave_cells.get(northwest).update_superposition(superposition, "northwest")
		
	if(_wave_cells.has(north)):
		_wave_cells.get(north).update_superposition(superposition, "north")
	
	if(_wave_cells.has(northeast)):
		_wave_cells.get(northeast).update_superposition(superposition, "northeast")
		
	if(_wave_cells.has(east)):
		_wave_cells.get(east).update_superposition(superposition, "east")
	
	if(_wave_cells.has(southeast)):
		_wave_cells.get(southeast).update_superposition(superposition, "southeast")
		
	if(_wave_cells.has(south)):
		_wave_cells.get(south).update_superposition(superposition, "south")
		
	if(_wave_cells.has(southwest)):
		_wave_cells.get(southwest).update_superposition(superposition, "southwest")
		
	if(_wave_cells.has(west)):
		_wave_cells.get(west).update_superposition(superposition, "west")

#This is to avoid recursion. We'll take everything that needs to be called and do it one at a time.
func _queuePropagation(superposition, location):
	_propagationQueue.append([superposition, location])
	
func _executePropagationQueue():
	var _propagateList = _propagationQueue.duplicate()
	_propagationQueue.clear()
	for arguments in _propagateList:
		_propagate(arguments[0], arguments[1])
		
func _processPropagations():
	while _propagationQueue.size() > 0:
		await _executePropagationQueue()
	
func _increment_tile_count(tile: Wave_Tile):
	for tile_resource in possible_tiles_resources:
		if (tile.tile_name == tile_resource.tile_name):
			tile.tiles_placed += 1
