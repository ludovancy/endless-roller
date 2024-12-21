extends Node3D

signal new_curve

@export var max_paths : int = 2

@onready var path_3d: Path3D = $Path3D
@onready var csg_polygon_3d: CSGPolygon3D = $CSGPolygon3D
@onready var path_3d_2: Path3D = $Path3D2
@onready var csg_polygon_3d_2: CSGPolygon3D = $CSGPolygon3D2
@onready var player: Node3D = $Player


func _ready():
	new_curve.emit(path_3d.curve)
	player.connect("request_new_path", make_new_path)

func make_new_path(paths_remaining):
	for i in range(max_paths - paths_remaining):
		# TODO: generate a different path
		print("Generated new path")
		new_curve.emit(path_3d.curve)
