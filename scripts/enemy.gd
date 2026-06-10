# enemy.gd
extends PathFollow2D

@export var stats: EnemyStats       # Resource containing health, speed, reward, etc.

var health: float
var speed: float
var alive: bool = true

signal died

func _ready():
	health = stats.max_health
	speed = stats.speed

func _process(delta):
	if not alive:
		return

	# Move forward along the path
	progress += speed * delta

	# Check if we reached the end of the curve
	var path_length = get_parent().curve.get_baked_length()
	if progress >= path_length:
		alive = false
		GameManager.lose_life(1)    # Enemy leaked through
		queue_free()

func take_damage(amount: float):
	if not alive:
		return
	health -= amount
	if health <= 0:
		alive = false
		emit_signal("died")
		GameManager.add_gold(stats.reward)
		queue_free()
