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

#Our sockets.
#T: Top, B: Bottom, L: Left, R: Right, M: Middle, C: Corner
#Refer to documentation for more info.
#Top
@export var socket_TL: String
@export var socket_TM: String
@export var socket_TR: String

#Bottom
@export var socket_BL: String
@export var socket_BM: String
@export var socket_BR: String

#Right
@export var socket_RT: String
@export var socket_RM: String
@export var socket_RB: String

#Left
@export var socket_LT: String
@export var socket_LM: String
@export var socket_LB: String

#Corners
@export var socket_CTL: String
@export var socket_CTR: String
@export var socket_CBL: String
@export var socket_CBR: String


#We can only be placed next to valid neighbors.
func is_valid(tile_list: Array, direction: String) -> bool:
	var valid = false
	for tile in tile_list:

		#The direction is our location FROM the tile that was updated.
		#i.e. northwest means we're northwest of the tile that we're comparing against.
		match direction:
			"northwest":
				if(socket_CBR == tile.socket_CTL):
					valid = true
			"north":
				if(socket_BL == tile.socket_TL && 
				socket_BM == tile.socket_TM && 
				socket_BR == tile.socket_TR):
					valid = true
			"northeast":
				if(socket_CBL == tile.socket_CTR):
					valid = true
			"east":
				if(socket_LT == tile.socket_RT && 
				socket_LM == tile.socket_RM && 
				socket_LB == tile.socket_RB):
					valid = true
			"southeast":
				if(socket_CTL == tile.socket_CBR):
					valid = true
			"south":
				if(socket_TL == tile.socket_BL && 
				socket_TM == tile.socket_BM && 
				socket_TR == tile.socket_BR):
					valid = true
			"southwest":
				if(socket_CTR == tile.socket_CBL):
					valid = true
			"west":
				if(socket_RT == tile.socket_LT && 
				socket_RM == tile.socket_LM && 
				socket_RB == tile.socket_LB):
					valid = true
	return valid
	
func _get_modified_weight():
	var modified = 1
	
	var calculated_limit: int
	calculated_limit = int(round(map_size * limit))
	
	if(limit == -1 || tiles_placed < calculated_limit):
		return weight
	else:
		modified = clampi(weight - weight_limit_penalty, 1, weight)
		return modified
