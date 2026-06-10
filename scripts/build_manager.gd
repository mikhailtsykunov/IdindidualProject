extends Node2D

@export var grid_size: Vector2i = Vector2i(64, 64)
@export var grid_offset: Vector2 = Vector2.ZERO
@export var path: Path2D
@export var tower_scene: PackedScene
@export var tile_map: TileMap

var occupied_cells: Dictionary = {}
var path_cells: Array[Vector2i] = []
var selected_tower: PackedScene = null

func _ready():
	selected_tower = tower_scene

	if tile_map:
		grid_size = tile_map.tile_set.tile_size
		grid_offset = tile_map.position
	else:
		pass   # <-- indented inside else

	compute_path_cells()


func compute_path_cells():
	path_cells.clear()
	if not path or not path.curve:
		return
	var curve: Curve2D = path.curve
	var length = curve.get_baked_length()
	var step = 4.0
	var d = 0.0
	while d <= length:
		var local_point = curve.sample_baked(d)
		var world_point = path.to_global(local_point)
		var cell = world_to_grid(world_point)
		if not path_cells.has(cell):
			path_cells.append(cell)
		d += step


func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local = world_pos - grid_offset
	return Vector2i(floor(local.x / grid_size.x), floor(local.y / grid_size.y))


func grid_to_world(cell: Vector2i) -> Vector2:
	return grid_offset + Vector2(cell.x * grid_size.x + grid_size.x / 2.0,
								  cell.y * grid_size.y + grid_size.y / 2.0)


func can_place(cell: Vector2i) -> bool:
	return not occupied_cells.has(cell) and not cell in path_cells


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_tower == null:
			return
		var cell = world_to_grid(get_global_mouse_position())
		if can_place(cell):
			place_tower(cell, selected_tower)
			get_tree().root.set_input_as_handled()


func place_tower(cell: Vector2i, tower_prefab: PackedScene):
	# Instantiate the tower to check its cost
	var tower = tower_prefab.instantiate()
	if not GameManager.can_afford(tower.stats.cost):
		tower.queue_free()   # don't leak memory
		return
	tower.global_position = grid_to_world(cell)
	add_child(tower)
	occupied_cells[cell] = true
	GameManager.spend(tower.stats.cost)
