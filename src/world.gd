extends Node3D

@export var points_in_curve : int = 10
@export var init_speed : float = 0.1
var speed = init_speed
var t : float = 0


@onready var player: Node3D = $Player
@onready var path_root: Node3D = $PathRoot

@export var max_paths : int = 4

@onready var node_3d: Node3D = $PathRoot/Node3D
@onready var node_3d_2: Node3D = $PathRoot/Node3D2
@onready var node_3d_3: Node3D = $PathRoot/Node3D3
@onready var node_3d_4: Node3D = $PathRoot/Node3D4

@onready var path_3d: Path3D = $PathRoot/Node3D/Path3D
@onready var path_3d_2: Path3D = $PathRoot/Node3D2/Path3D2
@onready var path_3d_3: Path3D = $PathRoot/Node3D4/Path3D3
@onready var path_3d_4: Path3D = $PathRoot/Node3D3/Path3D4

@onready var paths : Array[Path3D] = [path_3d, path_3d_2, path_3d_3, path_3d_4]
@onready var nodes : Array[Node3D] = [node_3d, node_3d_2, node_3d_3, node_3d_4]
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
	update_control_points(0.7, paths[index].curve)
	# place path
	var prev_path_index = posmod((index - 1), max_paths)
	var prev_path_pos := nodes[prev_path_index].position
	var last_point : Vector3 = Vector3.ZERO
	if paths[prev_path_index].curve.point_count > 0:
		last_point = paths[prev_path_index].curve.get_point_position(
			paths[prev_path_index].curve.point_count - 1
		)
	last_point = Vector3(0,0,(points_in_curve - 1) * 10)
	if (paths[prev_path_index].curve.point_count == 0):
		last_point = Vector3.ZERO
	nodes[index].position = prev_path_pos + last_point
	#paths[index].position = Vector3.ZERO
	print(paths[index].position)

func cycle_path():
	var initial_location : Vector3 = \
	paths[path_index].curve.get_point_position(
		paths[path_index].curve.point_count - 1
	)
	print(initial_location)
	initial_location = Vector3(0,0,(points_in_curve - 1) * 10)
	# move everything back
	for i in range(max_paths):
		nodes[i].translate(-1 * initial_location)
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
	#path_root.transform = move.inverse()
	path_root.transform = Transform3D(Basis(), 
		Vector3(0, 0, -t * (points_in_curve - 1) * 10))

#Convert Catmull-Rom to Bezier (Curve3D)
#For more information check out this paper:
#Tayebi Arasteh, S., & Kalisz, A. (2021). Conversion Between Cubic Bezier Curves and 
#Catmull–Rom Splines.
func update_control_points(torsion, curve):
	
	var k=torsion/3
	
	var pc=curve.get_point_count()
	
	if(pc<=1):
		return
	
	for i in range(0,pc-1):
		curve.set_point_out(i,k*(curve.get_point_position((i+1)%pc)-curve.get_point_position(fposmod(i-1, pc))))
		curve.set_point_in((i+1)%pc,-k*(curve.get_point_position((i+2)%pc)-curve.get_point_position(i%pc)))
	
	if(curve.get_point_position(0)==curve.get_point_position(pc-1)):
		curve.set_point_out(0,k*(curve.get_point_position(1)-curve.get_point_position(pc-2)))
		curve.set_point_in(pc-1,-k*(curve.get_point_position(1)-curve.get_point_position(pc-2)))
	else:
		curve.set_point_out(0,k*(curve.get_point_position(1)-curve.get_point_position(0)))
		curve.set_point_in(pc-1,-k*(curve.get_point_position(pc-1)-curve.get_point_position(pc-2)))
