extends Resource
class_name Wave_Tile

@export var tile_name: String
@export var weight: int = 10

#To be more clear: the index of the tile in the tilemap. It could be different depending checked which map we're using.
@export var source_id: int

#We can neighbor these tiles! Any other tiles are invalid.
@export var valid_neighbors: Array[String] = []

#We can only be placed next to valid neighbors.
func is_valid(tile_list: Array) -> bool:
	for valid_neighbor in valid_neighbors:
		for tile in tile_list:
			if(valid_neighbor == tile.tile_name):
				return true
	return false
