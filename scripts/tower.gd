# tower.gd
extends Area2D

@export var stats: TowerStats

var enemies_in_range: Array = []
var can_fire: bool = true

func _ready():
	# Set collision radius to match tower range
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = stats.range

	$AttackTimer.wait_time = 1.0 / stats.attack_speed

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta):
	# Clean up invalid enemies and fire at first valid one
	enemies_in_range = enemies_in_range.filter(
		func(e): return is_instance_valid(e) and e.alive
	)
	if enemies_in_range.size() > 0 and can_fire:
		fire(enemies_in_range[0])

func fire(target):
	can_fire = false
	$AttackTimer.start()

	var bullet = stats.bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.init(target, stats.damage)
	get_parent().add_child(bullet)

func _on_area_entered(area):
	var enemy = area.get_parent()
	if enemy is PathFollow2D and enemy.alive:
		enemies_in_range.append(enemy)

func _on_area_exited(area):
	var enemy = area.get_parent()
	enemies_in_range.erase(enemy)

func _on_attack_timer_timeout():
	can_fire = true
