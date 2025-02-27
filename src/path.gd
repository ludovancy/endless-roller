class_name CustomPath
extends Node3D

@onready var path: Path3D = $Path3D
@onready var csg_polygon_3d: CSGPolygon3D = $CSGPolygon3D
@onready var objects: Node3D = $Objects

const COIN = preload("res://bean.tscn")

@export var points_in_curve : int = 12
@export var custom_material := preload("res://res/path.tres")

func _ready() -> void:
	var material_color = Color(randf_range(0.3, 0.8),
			randf_range(0.3, 0.8),
			randf_range(0.3, 0.8))
	var mat = csg_polygon_3d.material
	if is_instance_of(mat, StandardMaterial3D):
		mat.albedo_color = material_color

func set_points_in_curve(points : int):
	points_in_curve = points

func get_baked_point(t: float) -> Transform3D:
	return path.curve.sample_baked_with_rotation(
		t * path.curve.get_baked_length(), true)

func get_last_point_position() -> Vector3:
	if path.curve.point_count == 0:
		return Vector3.ZERO
	return path.curve.get_point_position(path.curve.point_count - 1)

func make_new_path(
			prev_path_pos : Vector3 = Vector3.ZERO, 
			last_point : Vector3 = Vector3.ZERO):
	path.curve.clear_points()
	# procedural generation
	for i in range(points_in_curve):
		if i < 2 or i > points_in_curve - 3:
			path.curve.add_point(Vector3(0, 0, i*100))
			continue
		path.curve.add_point(
		Vector3(randf_range(-20, 20), randf_range(-20, 20), i*100))
	update_control_points(0.7)
	position = Vector3.ZERO
	
	# clear objects
	for child in objects.get_children():
		child.queue_free()
	
	# place new objects
	for i in range(8):
		var c : Node3D = COIN.instantiate()
		c.transform = get_baked_point((i + 2) * .09)
		objects.add_child(c)

	# place path
	position = prev_path_pos + last_point

#Convert Catmull-Rom to Bezier (Curve3D)
#For more information check out this paper:
#Tayebi Arasteh, S., & Kalisz, A. (2021). Conversion Between Cubic Bezier Curves and 
#Catmull–Rom Splines.
func update_control_points(torsion):
	
	var k : float = torsion/3
	
	var pc=path.curve.get_point_count()
	
	if(pc<=1):
		return
	
	for i in range(0,pc-1):
		var new_position : = path.curve.get_point_position((i+1)%pc) - \
					path.curve.get_point_position(posmod(i-1, pc))
		path.curve.set_point_out(i,k*new_position)
		path.curve.set_point_in((i+1)%pc,-k*(path.curve.get_point_position((i+2)%pc)-path.curve.get_point_position(i%pc)))
	
	if(path.curve.get_point_position(0)==path.curve.get_point_position(pc-1)):
		path.curve.set_point_out(0,k*(path.curve.get_point_position(1)-path.curve.get_point_position(pc-2)))
		path.curve.set_point_in(pc-1,-k*(path.curve.get_point_position(1)-path.curve.get_point_position(pc-2)))
	else:
		path.curve.set_point_out(0,k*(path.curve.get_point_position(1)-path.curve.get_point_position(0)))
		path.curve.set_point_in(pc-1,-k*(path.curve.get_point_position(pc-1)-path.curve.get_point_position(pc-2)))
