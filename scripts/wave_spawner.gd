extends Node

@export var path: Path2D
@export var enemy_scene: PackedScene
@export var waves: Array[Wave] = []

var current_wave_index: int = 0
var enemies_left_to_spawn: int = 0
var spawn_timer: Timer

func _ready():
	spawn_timer = $SpawnTimer
	print("WaveSpawner ready, waves: ", waves.size())
	start_next_wave()

func start_next_wave():
	if current_wave_index >= waves.size():
		print("No more waves (or none)!")
		return
	var wave = waves[current_wave_index]
	print("Starting wave ", current_wave_index, ", enemies: ", wave.count)
	enemies_left_to_spawn = wave.count
	spawn_timer.wait_time = wave.interval
	spawn_timer.start()

func _on_spawn_timer_timeout():
	print("Timer tick. Enemies left: ", enemies_left_to_spawn)
	if enemies_left_to_spawn <= 0:
		spawn_timer.stop()
		current_wave_index += 1
		print("Wave complete. Next wave index: ", current_wave_index)
		await get_tree().create_timer(2.0).timeout
		start_next_wave()
		return
	spawn_enemy(waves[current_wave_index].enemy_stats)
	enemies_left_to_spawn -= 1

func spawn_enemy(stats: EnemyStats):
	print("Spawning enemy with stats: ", stats)
	var enemy = enemy_scene.instantiate()
	print("Enemy spawned: ", enemy.name)
	path.add_child(enemy)
	enemy.stats = stats
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
	# The enemy signal already adds gold, so nothing to do here
	print("An enemy died")
