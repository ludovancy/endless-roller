extends Node3D

signal new_curve

@export var max_paths : int = 2
@export var points_in_curve : int = 10

@onready var player: Node3D = $Player
@onready var path_3d: Path3D = $PathRoot/Path3D
@onready var path_3d_2: Path3D = $PathRoot/Path3D2
@onready var path_3d_3: Path3D = $PathRoot/Path3D3

@onready var paths : Array[Path3D] = [path_3d, path_3d_2, path_3d_3]
var path_index := 0

func _ready():
	# generate max paths
	handle_new_path(0)
	player.connect("request_new_path", handle_new_path)

func handle_new_path(paths_remaining):
	for i in range(max_paths - paths_remaining):
		generate_path()

func generate_path():
	# get starting position of new path
	var starting_position : Vector3 = paths[path_index].position
	starting_position += paths[path_index].curve.get_point_position(
				paths[path_index].curve.point_count - 1
			)
	# start generating the new path 
	path_index = (path_index + 1) % len(paths)
	paths[path_index].position = starting_position
	paths[path_index].curve.clear_points()
	# procedural generation
	for i in range(points_in_curve):
		if i == 0:
			paths[path_index].curve.add_point(Vector3.ZERO)
			continue
		paths[path_index].curve.add_point(
		Vector3(i*10, randf_range(0,2), randf_range(-3, 3)))
	# send the curve to the player
	new_curve.emit(paths[path_index].curve)
