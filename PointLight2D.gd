extends PointLight2D

@export var item_type_1_brightness_factor: float = 100.0  # Factor to adjust brightness for item_type_1
@export var item_type_2_darkness_factor: float = 100.0    # Factor to adjust darkness for item_type_2
@onready var light: PointLight2D =                 # Reference to the Light2D node

var items_collected: Dictionary = {}  # Dictionary to store item counts

func _ready():
	if not light:
		push_error("Light2D is not found or is not set up correctly.")
		return

	# Initialize the item count dictionary (for demonstration)
	items_collected = {
		"item_type_1": 0,
		"item_type_2": 0
	}

func _process(delta):
	# Update the light based on collected items
	update_light_intensity()

func update_light_intensity():
	# Calculate brightness and darkness factors
	var brightness = items_collected.get("item_type_1", 0) * item_type_1_brightness_factor
	var darkness = items_collected.get("item_type_2", 0) * item_type_2_darkness_factor

	# Set light energy (brightness) by subtracting darkness from brightness
	light.energy = max(0, brightness - darkness)  # Ensure energy is not negative

	# Optionally adjust light color based on brightness
	# Example: light.color = Color(brightness, brightness, brightness)
