extends Node3D

@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@export var road_width : float = 3.0
var dragging: bool = false

func _input(event: InputEvent) -> void:
	var screen_x : float = get_viewport().get_visible_rect().size.x
	if event is InputEventMouseButton and \
			event.button_index == MOUSE_BUTTON_LEFT:
		# Start dragging if the click is on the sprite.
		if not dragging and event.pressed:
			dragging = true
		# Stop dragging if the button is released.
		if dragging and not event.pressed:
			dragging = false
	if dragging:
		var new_position = screen_x - clamp(event.position.x, 0, screen_x)
		new_position /= screen_x
		new_position *= road_width
		new_position -= road_width / 2
		character_body_3d.position.x = new_position
		print(new_position)
