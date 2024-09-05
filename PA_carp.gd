extends Line2D

@export var num_segments: int = 4
@export var segment_length: float = 25.0
@export var starting_pos: Vector2 = Vector2(100, 100)
@export var movement_speed: float = 250.0
@export var damping: float = 5.0
@export var smooth_factor: float = 0.9
@export var max_rotation_angle: float = 30.0
@export var collision_radius: float = 10.0  # Radius for collision detection
@export var collision_push_force: float = 5.0  # Force to push segments apart when they collide
@export var triangle_rotation_offset: float = 0.0 
@onready var particle_effect = $GPUParticles2D # Adjust the path if necessary

@export var joint_triangle_map: Dictionary = {
	1: [{ "angle": 90, "size": 15.0, "attach_by_point": false }],
	2: [{ "angle": 90, "size": 25.0, "attach_by_point": false }],
	3: [{ "angle": 180, "size": 40.0, "attach_by_point": true }],
}


var velocity: Vector2 = Vector2.ZERO
var segment_angles: Array = []
@onready var collision_shapes: Array = []


func _ready():
	for i in range(num_segments):
		add_point(starting_pos)
		segment_angles.append(0.0)
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = CircleShape2D.new()
		collision_shape.shape.radius = collision_radius
		add_child(collision_shape)
		collision_shapes.append(collision_shape)

func _process(delta):
	var input_movement: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_movement.y += 1
	if Input.is_action_pressed("ui_left"):
		input_movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement.x += 1

	if input_movement.length() > 0:
		input_movement = input_movement.normalized() * movement_speed

	velocity = velocity.lerp(input_movement, damping * delta)

	var previous_positions: Array = []
	for i in range(num_segments):
		previous_positions.append(get_point_position(i))

	var current_position: Vector2 = get_point_position(0)
	set_point_position(0, current_position + velocity * delta)

	for point_index in range(1, num_segments):
		var previous_point_pos: Vector2 = get_point_position(point_index - 1)
		var current_point_pos: Vector2 = get_point_position(point_index)

		var direction: Vector2 = (previous_point_pos - current_point_pos).normalized()
		var target_angle = direction.angle()
		
		var current_angle = segment_angles[point_index]
		var angle_difference = wrapf(target_angle - current_angle, -PI, PI)

		if abs(rad_to_deg(angle_difference)) > max_rotation_angle:
			angle_difference = deg_to_rad(sign(angle_difference) * max_rotation_angle)
		
		current_angle += angle_difference
		segment_angles[point_index] = current_angle
		
		var target_position = previous_point_pos - Vector2(cos(current_angle), sin(current_angle)) * segment_length
		set_point_position(point_index, current_point_pos.lerp(target_position, smooth_factor))

	for i in range(num_segments):
		collision_shapes[i].position = get_point_position(i)

	# Check and resolve collisions
	resolve_collisions()

func resolve_collisions():
	var push_offsets: Dictionary = {}  # Store how much each segment needs to be pushed

	for i in range(num_segments):
		for j in range(i + 1, num_segments):
			var pos_i = collision_shapes[i].position
			var pos_j = collision_shapes[j].position
			if pos_i.distance_to(pos_j) < collision_radius * 2:
				var direction = (pos_j - pos_i).normalized()
				var overlap = collision_radius * 2 - pos_i.distance_to(pos_j)
				var push_distance = overlap * collision_push_force

				if not push_offsets.has(i):
					push_offsets[i] = Vector2.ZERO
				if not push_offsets.has(j):
					push_offsets[j] = Vector2.ZERO

				push_offsets[i] -= direction * (push_distance / 2)
				push_offsets[j] += direction * (push_distance / 2)

	# Update segment positions after resolving collisions
	for i in range(num_segments):
		if push_offsets.has(i):
			set_point_position(i, get_point_position(i) + push_offsets[i])

	# Apply additional smoothing to ensure smooth movement after resolving collisions
	for i in range(num_segments):
		var pos = get_point_position(i)
		set_point_position(i, pos.lerp(get_point_position(i) + push_offsets.get(i, Vector2.ZERO), smooth_factor))

func _draw():
	for point_index in range(get_point_count()):
		var point_position: Vector2 = get_point_position(point_index)
		draw_circle(point_position, 10, Color.ORANGE_RED)
		
		if joint_triangle_map.has(point_index):
			var triangles_data: Array = joint_triangle_map[point_index]
			for triangle_data in triangles_data:
				var relative_angle = triangle_data.angle
				var size = triangle_data.size
				var attach_by_point = triangle_data.get("attach_by_point", false)
				var segment_angle = rad_to_deg(segment_angles[point_index])
				var total_angle = segment_angle + relative_angle
				var triangle_position = point_position + Vector2(cos(deg_to_rad(total_angle)), sin(deg_to_rad(total_angle))) * (segment_length if attach_by_point else segment_length / 2)
				draw_triangle(triangle_position, total_angle, size, attach_by_point)

func draw_triangle(position: Vector2, angle: float, size: float, attach_by_point: bool):
	var offset1: Vector2
	var offset2: Vector2
	var offset3: Vector2

	var adjusted_angle = angle

	if attach_by_point:
		# Apply additional rotation offset when attaching by point
		adjusted_angle += triangle_rotation_offset

		# Offset1 is the tip (pointed end), so it should be at the position
		offset1 = Vector2(0, -size / 2).rotated(deg_to_rad(adjusted_angle))
		# Offsets for the base of the triangle
		offset2 = Vector2(-size / 2, size / 2).rotated(deg_to_rad(adjusted_angle))
		offset3 = Vector2(size / 2, size / 2).rotated(deg_to_rad(adjusted_angle))
	else:
		# No additional rotation when attaching by edge
		offset1 = Vector2(-size / 2, size / 2).rotated(deg_to_rad(adjusted_angle))
		offset2 = Vector2(size / 2, size / 2).rotated(deg_to_rad(adjusted_angle))
		offset3 = Vector2(0, -size / 2).rotated(deg_to_rad(adjusted_angle))

	# Calculate the actual positions of the triangle's vertices
	var point1 = position + offset1
	var point2 = position + offset2
	var point3 = position + offset3

	# Draw the triangle
	draw_polygon([point1, point2, point3], [Color.ORANGE])
	update_particle_position()

func update_particle_position():
	for point_index in range(get_point_count()):
		if joint_triangle_map.has(point_index):
			var triangles_data: Array = joint_triangle_map[point_index]
			for triangle_data in triangles_data:
				var attach_by_point = triangle_data.get("attach_by_point", false)
				if attach_by_point:
					var relative_angle = triangle_data.angle
					var size = triangle_data.size
					var segment_angle = rad_to_deg(segment_angles[point_index])
					var total_angle = segment_angle + relative_angle

					# Calculate the position of the triangle tip
					var triangle_tip_position = get_point_position(point_index) + \
						Vector2(cos(deg_to_rad(total_angle)), sin(deg_to_rad(total_angle))) * (size / 2)

					# Update the particle effect position to the triangle tip
					particle_effect.position = triangle_tip_position
