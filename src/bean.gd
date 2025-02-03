extends Node3D
@onready var base: Area3D = $Base
@onready var mesh_instance_3d: MeshInstance3D = $Base/MeshInstance3D
@onready var animation_player: AnimationPlayer = $Base/MeshInstance3D/AnimationPlayer

@export var width = 8.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base.position.x = randf_range(-width / 2, width / 2)
	animation_player.speed_scale = randf_range(1, 2)
	animation_player.play("rotate")


func _on_base_body_entered(body: Node3D) -> void:
	print("Coin")
	mesh_instance_3d.visible = false
	queue_free()
