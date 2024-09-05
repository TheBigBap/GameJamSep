extends Line2D

@export var num_segments: int = 6
@export var segment_length: float = 15.0
@export var starting_pos: Vector2 = Vector2(100, 100)
@export var movement_speed: float = 250.0  # Speed at which the line moves
@export var damping: float = 5.0  # Damping factor for underwater effect
@export var smooth_factor: float = 0.9  # How smoothly points follow each other

var velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(num_segments):
		add_point(starting_pos)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle movement input
	var input_movement: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_movement.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement.x += 1
	if Input.is_action_pressed("ui_right"):
		input_movement.x -= 1

	# Normalize the input movement vector to ensure consistent speed
	if input_movement.length() > 0:
		input_movement = input_movement.normalized() * movement_speed

	# Apply damping to the velocity to simulate underwater resistance
	velocity = velocity.lerp(input_movement, damping * delta)

	# Update the position of the first point based on the velocity
	var current_position: Vector2 = get_point_position(0)
	set_point_position(0, current_position + velocity * delta)

	# Make each subsequent point follow the previous one with smoothing
	for point_index in range(1, num_segments):
		var previous_point_pos: Vector2 = get_point_position(point_index - 1)
		var current_point_pos: Vector2 = get_point_position(point_index)
		
		# Calculate the direction from the current point to the previous one
		var direction: Vector2 = (previous_point_pos - current_point_pos).normalized()
		
		# Smoothly update the current point position to follow the previous one
		var target_position = previous_point_pos - direction * segment_length
		set_point_position(point_index, current_point_pos.lerp(target_position, smooth_factor))

func _draw():
	# Optional: Visualize the points as circles
	for point_index in range(get_point_count()):
		var point_position: Vector2 = get_point_position(point_index)
		draw_circle(point_position, 1, Color.ORANGE_RED)
