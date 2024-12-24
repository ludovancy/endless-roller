extends Node3D

@export var points_in_curve : int = 10
@export var init_speed : float = 0.15
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
		Vector3(randf_range(-5, 5), 0, i*10))
	# place path
	var prev_path_index = posmod((index - 1), max_paths)
	var prev_path_pos := paths[prev_path_index].position
	var last_point : Vector3 = Vector3.ZERO
	if paths[prev_path_index].curve.point_count > 0:
		last_point = paths[prev_path_index].curve.get_point_position(
			paths[prev_path_index].curve.point_count - 1
		)
	paths[index].position = prev_path_pos + last_point

func cycle_path():
	var initial_location : Vector3 = \
	paths[path_index].curve.get_point_position(
		paths[path_index].curve.point_count - 1
	)
	# move everything back
	for i in range(max_paths):
		paths[i].translate(-1 * initial_location)
	# advance
	path_index = (path_index + 1) % max_paths
	generate_path(posmod((path_index - 2), max_paths)) # no negative numbers

func _process(delta: float) -> void:
	t += delta * speed
	if t >= 1.0:
		t -= 1.0
		cycle_path()
	var move := paths[path_index].curve.sample_baked_with_rotation(
		t * paths[path_index].curve.get_baked_length(), true)
	print(move)
	path_root.transform = move.inverse()
	#path_root.transform = Transform3D(Basis(), Vector3(0, 0, -t * 90))
