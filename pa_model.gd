extends CharacterBody2D  # Assuming CharacterBody2D is the base class for your player

var items_collected: Dictionary = {}  # Dictionary to store item counts

@onready var item_area: Area2D = $PA_carp/item_area  # Reference to the Area2D node
@onready var line2d: Line2D = $PA_carp  # Reference to the Line2D node
@onready var item_counter_label: Label = $PA_carp/CanvasLayer/ItemCounterLabel  # Reference to the Label node for displaying item counts

func _ready():
	if not item_area:
		push_error("item_area is not found or is not set up correctly.")
		return
	
	if not line2d:
		push_error("Line2D is not found or is not set up correctly.")
		return

	# Initialize dictionary for item counts
	items_collected = {
		"item_type_1": 0,
		"item_type_2": 0
		# Add more item types as needed
	}

	# Connect the area_entered signal to a function for automatic item collection
	item_area.connect("area_entered", Callable(self, "_on_item_area_entered"))
	
	# Initialize the item count display
	update_item_count_display()

func _process(delta):
	# Ensure Area2D follows the first point of the Line2D
	if line2d.get_point_count() > 0:
		item_area.global_position = line2d.get_point_position(0)

func _on_item_area_entered(area: Area2D):
	# This function is called when an Area2D enters the item_area
	if area.has_method("emit_signal") and area.has_signal("item_picked_up"):
		area.emit_signal("item_picked_up", area.item_type)
		
		# Safely handle the item_type in the dictionary
		if not items_collected.has(area.item_type):
			items_collected[area.item_type] = 0  # Initialize if it doesn't exist
		
		items_collected[area.item_type] += 1
		update_item_count_display()
		print("Picked up:", area.item_type, "Total:", items_collected[area.item_type])

func update_item_count_display():
	# Create a string to display item counts
	var item_count_text = "Items Collected:\n"
	
	for item_type in items_collected.keys():
		item_count_text += "%s: %d\n" % [item_type, items_collected[item_type]]
	
	# Update the Label's text
	item_counter_label.text = item_count_text
