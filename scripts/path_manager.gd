# path_manager.gd
extends Node2D

@export var waypoints: Array[Marker2D] = []

func _ready():
	# Automatically gather children Marker2Ds in order
	for child in get_children():
		if child is Marker2D:
			waypoints.append(child)

func get_waypoint(index: int) -> Marker2D:
	if index < waypoints.size():
		return waypoints[index]
	return null

func get_start_position() -> Vector2:
	if waypoints.size() > 0:
		return waypoints[0].global_position
	return Vector2.ZERO
