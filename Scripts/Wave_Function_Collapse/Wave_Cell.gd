#Represents a cell on a tilemap. Responsible for determining which tiles it could be
#and which one to place.
extends Node2D
class_name Wave_Cell

signal updated_tiles(superposition: Array, location: Vector2i)
signal placed_tile(tile_name: String)

@export var possible_tiles_resources: Array[Wave_Tile] = []

var possible_tile_nodes: Array[Wave_Tile] = []

var location: Vector2i
var tileMap: TileMap
	
func init(vector_init: Vector2i, tileMap_init: TileMap):
	location = vector_init
	tileMap = tileMap_init
	
	_populate_tiles()
	
#If another tile has collapsed or updated its valid tiles, we need to update ourselves as well.
func update_superposition(updated_cell_location: Vector2i, cell_superposition):
	var tile_nodes_to_be_erased: Array[Wave_Tile] = []
	var has_changed = false
	
	if(_is_adjacent(updated_cell_location)):
		for possible_tile in possible_tile_nodes:
			if(!possible_tile.is_valid(cell_superposition)):
				#Don't erase from the array you're iterating over!
				tile_nodes_to_be_erased.append(possible_tile)
				has_changed = true
				
	for erased_tile in tile_nodes_to_be_erased:
		possible_tile_nodes.erase(erased_tile)
		
	if(has_changed):
		updated_tiles.emit(possible_tile_nodes, location)

#Remember a POSITIVE y value is DOWN
func _is_adjacent(foreign_location: Vector2i) -> bool:
	#var north_west = location + Vector2i(-1, -1)
	var north = location + Vector2i(0, -1)
	#var north_east = location + Vector2i(1, -1)
	var east = location + Vector2i(1, 0)
	#var south_east = location + Vector2i(1, 1)
	var south = location + Vector2i(0, 1)
	#var south_west = location + Vector2i(-1, 1)
	var west = location + Vector2i(-1, 0)
	
#	match foreign_location:
#		north_west, north, north_east, east, south_east, south, south_west, west:
#			return true
#		_:
#			return false
			
	match foreign_location:
		north, east, south, west:
			return true
		_:
			return false

#Become a tile from our available list.
func collapse():
	if(possible_tile_nodes.size() == 0):
		print_debug("Oops!")
		updated_tiles.emit(possible_tile_nodes, location)
		return

	var collapsed_tile: Wave_Tile = _weighted_random_tile()
	
	possible_tile_nodes.clear()
	possible_tile_nodes.append(collapsed_tile)
	
	_place_tile(collapsed_tile, 0)
	

#We don't exactly want to tamper with the resources themselves.
func _populate_tiles():
	for node in possible_tiles_resources:
		possible_tile_nodes.append(node)
		
func _place_tile(tile: Wave_Tile, layer: int):
	var tile_id = tile.source_id
	var atlas_coords = tile.atlas_coords
	
	tileMap.set_cell(layer, location, tile_id, atlas_coords)
	updated_tiles.emit(possible_tile_nodes, location)
	placed_tile.emit(tile.tile_name)
	
func _weighted_random_tile() -> Wave_Tile:
	var weight_total = 0
	var offset = 0
	
	var random = RandomNumberGenerator.new()
	
	for node in possible_tile_nodes:
		weight_total += node.modified_weight
	
	random.randomize() 
	var rolled_value = weight_total - random.randi_range(offset, weight_total)
	
	for node in possible_tile_nodes:
		if(node.modified_weight + offset >= rolled_value):
			return node
		else:
			offset += node.modified_weight
			
	#If we somehow don't return a node before this. Shouldn't happen.
	return null
