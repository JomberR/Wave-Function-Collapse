extends Node2D
class_name Wave_Function_Collapse

@export var height: int = 15
@export var width: int = 25

@export var tileMap: TileMap
@export var wave_cell: PackedScene

@export var placement_delay: float = .01

var _wave_cells: Array = []
var _delay: float

# Called when the node enters the scene tree for the first time.
func _ready():
	#_populate_random_tilemap()
	_populate_cells(wave_cell)
#	while _wave_cells.size() > 0:
#		_collapse_cell()
	_delay = placement_delay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_delay -= delta

	if(_delay <= 0):
		_delay = placement_delay;
		if(_wave_cells.size() > 0):
			_collapse_cell()

func _populate_random_tilemap():
	for x in width:
		for y in height:
			_place_random_tile(Vector2i(x, y), tileMap.tile_set)

func _place_random_tile(tile_position: Vector2i, tileset: TileSet):
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	var tileset_size = tileset.get_source_count()
	var random_tile = random.randi_range(0, tileset_size - 1)
	
	#layer, coordinates, source, atlas_coords
	tileMap.set_cell(0, tile_position, random_tile, Vector2i(0,0))

func _populate_cells(cell):
	for x in width:
		for y in height:
			_create_cell(Vector2i(x,y), cell)

func _create_cell(location: Vector2i, cell: PackedScene):
	var node: Wave_Cell = cell.instantiate()
	node.updated_tiles.connect(_propagate)
	node.init(location, tileMap)
	_wave_cells.append(node)
	
func _collapse_cell():
	if(_wave_cells.size() <= 0):
		return
		
	_wave_cells.sort_custom(_cell_sort)
	var cell = _wave_cells.pop_front()
	cell.collapse()
	
func _cell_sort(a, b):
	var entropy_a = a.possible_tile_nodes.size()
	var entropy_b = b.possible_tile_nodes.size()
	
	if(entropy_a < entropy_b):
		return true
	else:
		return false

func _collapse_random_cell():
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	if(_wave_cells.size() <= 0):
		return
	
	var rand_int = random.randi_range(0, _wave_cells.size() - 1)
	
	_wave_cells[rand_int].collapse()
	_wave_cells.remove_at(rand_int)

func _propagate(superposition, location):
	for cell in _wave_cells:
		cell.update_superposition(location, superposition)
	
	
