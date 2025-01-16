extends Node3D
@onready var base: Area3D = $Base

@export var width = 8.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base.position.x = randf_range(-width / 2, width / 2)
