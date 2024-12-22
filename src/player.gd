extends Node3D

signal request_new_path(paths_remaining)

@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@export var road_width : float = 9.0
@export var init_speed : float = 0.2
var speed = init_speed
var dragging: bool = false

var t = 0
var curve : Curve3D = null
var next_curves : Array = []

func _ready() -> void:
	get_parent().connect("new_curve", set_new_curve)

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
		new_position *= -road_width
		new_position += road_width / 2
		character_body_3d.position.x = new_position

func _process(delta: float) -> void:
	if not curve:
		print("No curve")
		return
	t += delta * speed
	transform = curve.sample_baked_with_rotation(t * curve.get_baked_length(), true)
	if t > 1:
		t -= 1
		curve = next_curves.pop_front()
		request_new_path.emit(len(next_curves))

func set_new_curve(new_curve : Curve3D):
	if curve == null:
		curve = new_curve
		return
	next_curves.append(new_curve)
