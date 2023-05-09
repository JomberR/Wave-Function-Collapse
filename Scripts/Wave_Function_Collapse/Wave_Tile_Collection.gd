#Holds wave_tiles. This resources exists solely for organizational purposes.
#Having an array with 20+ tiles for the entire tilemap is obnoxious.

extends Resource
class_name Wave_Tile_Collection

@export var wave_tiles: Array[Wave_Tile] = []
