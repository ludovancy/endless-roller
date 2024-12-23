extends Node3D

@export var points_in_curve : int = 10
@export var init_speed : float = 0.1
var speed = init_speed
var t : float = 0


@onready var player: Node3D = $Player
@onready var path_root: Node3D = $PathRoot

@export var max_paths : int = 3
@onready var path_3d: Path3D = $PathRoot/Path3D
@onready var path_3d_2: Path3D = $PathRoot/Path3D2
@onready var path_3d_3: Path3D = $PathRoot/Path3D3

@onready var paths : Array[Path3D] = [path_3d, path_3d_2, path_3d_3]
var path_index := 0

func _ready():
	# generate max paths
	for i in range(max_paths):
		generate_path(i)

func generate_path(index:int):
	paths[index].curve.clear_points()
	# procedural generation
	for i in range(points_in_curve):
		if i == 0:
			paths[index].curve.add_point(Vector3.ZERO)
			continue
		paths[index].curve.add_point(
		Vector3(i*10, randf_range(0,2), randf_range(-3, 3)))
	# place path
	paths[index].position = paths[(index - 1) % max_paths].position
	var last_point : Vector3 = Vector3.ZERO
	if paths[(index - 1) % max_paths].curve.point_count > 0:
		last_point = paths[(index - 1) % max_paths].curve.get_point_position(
			paths[(index - 1) % max_paths].curve.point_count - 1
		)
	paths[index].position += last_point

func cycle_path():
	# get starting position of new path
	var starting_position : = path_root.position
	# move everything back
	path_root.position = Vector3.ZERO
	for i in range(max_paths):
		paths[i].position = Vector3.ZERO + starting_position
	# advance
	path_index = (path_index + 1) % max_paths
	generate_path((path_index - 2) % max_paths)

func _process(delta: float) -> void:
	t += delta * speed
	var move := paths[path_index].curve.sample_baked_with_rotation(
		t * paths[path_index].curve.get_baked_length(), true)
	path_root.transform = move.inverse()
	player.transform.basis = move.basis
	if t >= 1.0:
		t -= 1.0
		cycle_path()
