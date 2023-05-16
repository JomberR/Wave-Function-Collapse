extends Camera2D

@export var move_speed: float = 1500

@export var zoom_speed: float = 2
@export var zoom_min: float = .25
@export var zoom_max: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_movement(delta)
	_zoom(delta)
	
func _movement(delta):
	var x = 0
	var y = 0
	
	if (Input.is_action_pressed("move_up")):
		y -= 1
	if (Input.is_action_pressed("move_down")):
		y += 1
	if (Input.is_action_pressed("move_left")):
		x -= 1
	if (Input.is_action_pressed("move_right")):
		x += 1
		
	var velocity = Vector2(x, y) * move_speed * delta
	self.position += velocity
	
func _zoom(delta):
	var x = 0
	var y = 0
	
	if(Input.is_action_just_released("ui_zoom_in")):
		x += 1
		y += 1
	if(Input.is_action_just_released("ui_zoom_out")):
		x -= 1
		y -= 1
	
	var zoom_amount = Vector2(x, y) * zoom_speed * delta
	var new_zoom: Vector2 = self.zoom + zoom_amount
	self.zoom = new_zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
