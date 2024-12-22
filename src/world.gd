extends Node3D

signal new_curve

@export var max_paths : int = 2

@onready var player: Node3D = $Player
@onready var path_3d: Path3D = $Path3D
@onready var path_3d_2: Path3D = $Path3D2
@onready var path_3d_3: Path3D = $Path3D3

@onready var paths : Array[Path3D] = [path_3d, path_3d_2, path_3d_3]
var path_index := 0

func _ready():
	new_curve.emit(path_3d.curve)
	player.connect("request_new_path", handle_new_path)
	generate_path()

func handle_new_path(paths_remaining):
	for i in range(max_paths - paths_remaining):
		generate_path()

func generate_path():
	print("Generating path #", path_index)
	new_curve.emit(paths[path_index].curve)
	path_index = (path_index + 1) % len(paths)
