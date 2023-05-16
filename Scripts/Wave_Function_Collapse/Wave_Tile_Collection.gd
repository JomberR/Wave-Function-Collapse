#Holds wave_tiles. This resources exists solely for organizational purposes.
#Having an array with 20+ tiles for the entire tilemap is obnoxious.
#Also sets global modifiers for each tile because editing each individaul tile-
	#-is a nightmare

extends Resource
class_name Wave_Tile_Collection

@export var wave_tiles: Array[Wave_Tile]:
	get = _get_wave_tiles
		
@export var weight_modifier: int = 0
@export var limit_modifier: float = 0
@export var weight_limit_penalty_modifier: int = 0

func _get_wave_tiles():
	for tile in wave_tiles:
		tile.weight_modifier = weight_modifier
		
		#The limit modifier should represent the collection as a whole, not the individual tiles
		tile.limit_modifier = limit_modifier / float(wave_tiles.size())
		
		tile.weight_limit_penalty_modifier = weight_limit_penalty_modifier
	return wave_tiles
	
	
