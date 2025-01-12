extends Control

signal unpause
@onready var animation_player: AnimationPlayer = $PanelContainer/CenterContainer/VBoxContainer/HBoxContainer/Control/AnimationPlayer

func _ready() -> void:
	animation_player.play("slide")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
			event.button_index == MOUSE_BUTTON_LEFT:
		unpause.emit()
		get_tree().paused = false
		visible = false

func _on_pause():
	visible = true
