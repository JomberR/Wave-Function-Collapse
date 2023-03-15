#The overall manager. Responsible for populating the tilemap with cells, and calling them.
#It is also responsible for managing tile resources within the cells.
extends Node2D
class_name Wave_Function_Collapse

@export var height: int = 15
@export var width: int = 25

@export var tileMap: TileMap
@export var wave_cell: PackedScene

@export var placement_delay: float = .01
@export var tiles_to_place: int = 1

var _wave_cells: Array = [Wave_Cell]
var _delay: float
var _is_generating: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	_populate_cells(wave_cell)
#	_collapse_random_cell()
	_delay = placement_delay
	
func generate_map():
	tileMap.clear()
	_wave_cells.clear()
	
	_populate_cells(wave_cell)
	_collapse_random_cell()
	_is_generating = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_delay -= delta

	if(_delay <= 0):
		_delay = placement_delay
		
		if(_is_generating):
			for i in tiles_to_place:
				_collapse_cell()
			if(_wave_cells.size() <= 0):
				_is_generating = false

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
		
	var cell = _find_lowest_entropy()
	cell.collapse()
	
func _cell_sort(a, b):
	var entropy_a = a.possible_tile_nodes.size()
	var entropy_b = b.possible_tile_nodes.size()
	
	if(entropy_a < entropy_b):
		return true
	else:
		return false
		
func _find_lowest_entropy() -> Wave_Cell:
	
	var lowest_cell: Wave_Cell = _wave_cells.pick_random()
	
	for cell in _wave_cells:
		if (lowest_cell.possible_tile_nodes.size() > cell.possible_tile_nodes.size()):
			lowest_cell = cell
	_wave_cells.erase(lowest_cell)
	
	return lowest_cell
		

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
	
	
