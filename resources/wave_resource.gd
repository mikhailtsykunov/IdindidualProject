# wave_resource.gd
class_name Wave
extends Resource

@export var count: int = 5
@export var interval: float = 1.0
@export var enemy_stats: EnemyStats   # which enemy type to spawn
