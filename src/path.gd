class_name CustomPath
extends Node3D

@onready var path: Path3D = $Path3D
@onready var csg_polygon_3d: CSGPolygon3D = $CSGPolygon3D

var points_in_curve : int = 10

func _ready() -> void:
	csg_polygon_3d.material

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
		if i == 0:
			path.curve.add_point(Vector3.ZERO)
			continue
		path.curve.add_point(
		Vector3(randf_range(-5, 5), 0, i*10))
	update_control_points(0.7)
	# place path
	position = prev_path_pos + last_point
	print(position)

#Convert Catmull-Rom to Bezier (Curve3D)
#For more information check out this paper:
#Tayebi Arasteh, S., & Kalisz, A. (2021). Conversion Between Cubic Bezier Curves and 
#Catmull–Rom Splines.
func update_control_points(torsion):
	
	var k=torsion/3
	
	var pc=path.curve.get_point_count()
	
	if(pc<=1):
		return
	
	for i in range(0,pc-1):
		path.curve.set_point_out(i,k*(path.curve.get_point_position((i+1)%pc)-path.curve.get_point_position(fposmod(i-1, pc))))
		path.curve.set_point_in((i+1)%pc,-k*(path.curve.get_point_position((i+2)%pc)-path.curve.get_point_position(i%pc)))
	
	if(path.curve.get_point_position(0)==path.curve.get_point_position(pc-1)):
		path.curve.set_point_out(0,k*(path.curve.get_point_position(1)-path.curve.get_point_position(pc-2)))
		path.curve.set_point_in(pc-1,-k*(path.curve.get_point_position(1)-path.curve.get_point_position(pc-2)))
	else:
		path.curve.set_point_out(0,k*(path.curve.get_point_position(1)-path.curve.get_point_position(0)))
		path.curve.set_point_in(pc-1,-k*(path.curve.get_point_position(pc-1)-path.curve.get_point_position(pc-2)))
