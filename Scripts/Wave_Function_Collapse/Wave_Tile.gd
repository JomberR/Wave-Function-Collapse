extends Resource
class_name Wave_Tile

@export var tile_name: String

#This should be a percentage
@export var limit: float = -1

@export var weight: int = 10
@export var weight_limit_penalty: int = 0

#Our weight that we want to use for calculations may be different from our starting weight.
	#For example, if we want to reduce the weight if we have over a certain amount of tiles.
var modified_weight: int:
	get = _get_modified_weight
	
#A manager should modify/reset/keep track of this value.
var tiles_placed = 0
var map_size: int

#To be more clear: the index of the tile in the tilemap. It could be different depending checked which map we're using.
@export var source_id: int
@export var atlas_coords: Vector2i = Vector2i(0,0)

#We can neighbor tiles in specific directions. If it's not there, it's invalid.
@export var valid_neighbors_northwest: Array[String] = []
@export var valid_neighbors_north: Array[String] = []
@export var valid_neighbors_northeast: Array[String] = []
@export var valid_neighbors_east: Array[String] = []
@export var valid_neighbors_southeast: Array[String] = []
@export var valid_neighbors_south: Array[String] = []
@export var valid_neighbors_southwest: Array[String] = []
@export var valid_neighbors_west: Array[String] = []

#We can only be placed next to valid neighbors.
#CHANGE: we need a second argument that tells us whether or not we're north/south/east/west etc.
func is_valid(tile_list: Array, direction: String) -> bool:
	var valid = false
	match direction:
		"northwest":
			valid = _check_neighbors(tile_list, valid_neighbors_northwest)
		"north":
			valid = _check_neighbors(tile_list, valid_neighbors_north)
		"northeast":
			valid = _check_neighbors(tile_list, valid_neighbors_northeast)
		"east":
			valid = _check_neighbors(tile_list, valid_neighbors_east)
		"southeast":
			valid = _check_neighbors(tile_list, valid_neighbors_southeast)
		"south":
			valid = _check_neighbors(tile_list, valid_neighbors_south)
		"southwest":
			valid = _check_neighbors(tile_list, valid_neighbors_southwest)
		"west":
			valid = _check_neighbors(tile_list, valid_neighbors_west)
			
	return valid
			
func _check_neighbors(tile_list: Array, valid_neighbors: Array):
	#Tile_list is the list of possible tiles in our neighbor.
	for valid_neighbor in valid_neighbors:
		for tile in tile_list:
			if(valid_neighbor == tile.tile_name):
				return true
	return false
	
func _get_modified_weight():
	var modified = 1
	
	var calculated_limit: int
	calculated_limit = int(round(map_size * limit))
	
#	print(str(tile_name) + ": Limit " + str(calculated_limit))
#	print(str(tile_name) + ": Total " + str(tiles_placed))
	
	if(limit == -1 || tiles_placed < calculated_limit):
#		print(str(tile_name) + ": Weight " + str(weight))
		return weight
	else:
		modified = clampi(weight - weight_limit_penalty, 1, weight)
#		print(str(tile_name) + ": Weight " + str(modified))
		return modified
