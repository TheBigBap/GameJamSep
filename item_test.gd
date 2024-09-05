extends Area2D

@export var item_type: String = "item"  # The type of the item
@export var item_value: String = "value"
@export var move_speed: float = 100.0  # Speed at which the item moves
@export var change_direction_interval: float = 2.0  # Time interval to change direction

var direction: Vector2 = Vector2.ZERO
var time_since_last_direction_change: float = 0.0

# Signal to notify when the item is picked up
signal item_picked_up(item_type: String)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Initialize the direction with a random value
	_change_direction()

func _process(delta):
	# Update position based on movement direction and speed
	position += direction * move_speed * delta
	
	# Handle direction change
	time_since_last_direction_change += delta
	if time_since_last_direction_change >= change_direction_interval:
		_change_direction()
		time_since_last_direction_change = 0.0
	# Check if the item is within the boundary polygon
	
func _on_body_entered(body):
	# Change direction upon collision
	direction = -direction

func _change_direction():
	# Set a new random direction
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _on_area_entered(body):
	if body.is_in_group("world_object"):
		direction = -direction 
	elif body.is_in_group("item"):
		direction = -direction 
	else:
		queue_free()
