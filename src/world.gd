extends Node3D

signal new_curve

@onready var path_3d: Path3D = $Path3D
@onready var csg_polygon_3d: CSGPolygon3D = $CSGPolygon3D
@onready var path_3d_2: Path3D = $Path3D2
@onready var csg_polygon_3d_2: CSGPolygon3D = $CSGPolygon3D2


func _ready():
	new_curve.emit(path_3d.curve)
