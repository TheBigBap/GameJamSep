extends Node2D  # Or any node suitable for your scene structure

@export var item_scene_1: PackedScene  # Reference to the first item scene to spawn (item_1)
@export var item_scene_2: PackedScene  # Reference to the second item scene to spawn (item_2)
@export var spawn_interval: float = 5.0  # Time interval in seconds between spawns

@onready var spawn_timer: Timer = $"../SpawnTimer"  # Reference to the Timer node
@onready var markers: Node = $"."  # Reference to the parent node of Marker2D nodes

var marker_status: Dictionary = {}  # Keeps track of whether each marker is occupied

func _ready():
	if not item_scene_1 or not item_scene_2:
		push_error("Item scenes are not set for spawning.")
		return

	# Initialize marker statuses to available (false)
	for i in range(markers.get_child_count()):
		marker_status[i] = false  # Initialize all marker indices to false (available)
	
	# Start the timer with the set interval
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

	# Connect the timer's timeout signal to the spawn function
	spawn_timer.connect("timeout", Callable(self, "spawn_item"))

func spawn_item():
	# Get a list of available markers (those not occupied)
	var available_markers = []
	for i in range(markers.get_child_count()):
		if marker_status.has(i) and not marker_status[i]:  # Ensure the marker index exists and is not occupied
			available_markers.append(i)
	
	if available_markers.size() == 0:
		return  # No available markers, so don't spawn anything

	# Choose a random available marker
	var random_marker_index = available_markers[randi() % available_markers.size()]
	var random_marker = markers.get_child(random_marker_index) as Marker2D
	
	# Randomly select either item_scene_1 or item_scene_2
	var chosen_item_scene: PackedScene = item_scene_1 if randi() % 2 == 0 else item_scene_2
	
	# Instance the item and set its position to the chosen marker
	var item_instance = chosen_item_scene.instantiate()
	item_instance.position = random_marker.position
	add_child(item_instance)

	# Mark the marker as occupied
	marker_status[random_marker_index] = true
	
	# Connect the item's "item_picked_up" signal to mark the marker as available again
	item_instance.connect("item_picked_up", Callable(self, "on_item_picked_up").bind(random_marker_index))

func on_item_picked_up(marker_index, item_type, item_value):
	# Handle the item value based on whether the item was reversed or not
	# Assuming you have some system to handle these values
	print("Item picked up:", item_type, "Value:", item_value)
	
	# Ensure the marker index exists before trying to update its status
	if marker_status.has(marker_index):
		marker_status[marker_index] = false
