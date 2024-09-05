extends Polygon2D

@export var num_segments: int = 4
@export var segment_length: float = 100.0
@export var starting_pos: Vector2 = Vector2(100, 100)
@export var circle_radius: float = 10.0

var circle_positions: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize circle positions
	for i in range(num_segments):
		circle_positions.append(starting_pos)
	update_polygon()

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	circle_positions[0] = mouse_pos  # First point follows the mouse directly

	# Make each subsequent point follow the previous one
	for i in range(1, num_segments):
		var previous_pos = circle_positions[i - 1]
		var current_pos = circle_positions[i]
		
		# Calculate the direction from the current point to the previous one
		var direction = (previous_pos - current_pos).normalized()
		
		# Update the current position to follow the previous one
		circle_positions[i] = previous_pos - direction * segment_length
	
	update_polygon()
	update()  # Request the _draw method to be called

func update_polygon():
	var polygon_points: PoolVector2Array = PoolVector2Array()
	
	for pos in circle_positions:
		for i in range(360):
			var angle = deg2rad(i)
			var x = pos.x + circle_radius * cos(angle)
			var y = pos.y + circle_radius * sin(angle)
			polygon_points.append(Vector2(x, y))
	
	# Set the polygon points to approximate circles
	self.polygon = polygon_points

func _draw():
	# Draw circles with transparent fill and black outline
	for pos in circle_positions:
		draw_circle(pos, circle_radius, Color(0, 0, 0, 0), Color(0, 0, 0))
