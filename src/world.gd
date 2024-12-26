extends Node3D

signal set_points_in_curve(n : int)

@export var points_in_curve : int = 10
@export var init_speed : float = 0.1
var speed = init_speed
var t : float = 0
const path_obj = preload("res://path.tscn")
@onready var player: Node3D = $Player
@onready var path_root: Node3D = $PathRoot

@export var max_paths : int = 4

@onready var paths : Array[CustomPath] = []
var path_index := 0

func _ready():
	# create paths 
	for i in range(max_paths):
		var p : CustomPath = path_obj.instantiate()
		paths.append(p)
		path_root.add_child(p)
	# generate max paths
	set_points_in_curve.emit(points_in_curve)
	for i in range(max_paths):
		generate_path(i)

func generate_path(index:int):
	var prev_path_index := posmod(path_index - 1, max_paths)
	var prev_path_pos := paths[prev_path_index].position
	var last_point := paths[prev_path_index].get_last_point_position()
	paths[index].make_new_path(prev_path_pos, last_point)

func cycle_path():
	var initial_location := paths[path_index].get_last_point_position()
	print(initial_location)
	initial_location = Vector3(0,0,(points_in_curve - 1) * 10)
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
	var move := paths[path_index].get_baked_point(t)
	print(move)
	#path_root.transform = move.inverse()
	path_root.transform = Transform3D(Basis(), 
		Vector3(0, 0, -t * (points_in_curve - 1) * 10))
