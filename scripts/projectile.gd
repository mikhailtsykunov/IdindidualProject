# projectile.gd
extends Area2D

var target: PathFollow2D
var damage: float
var speed: float = 400.0

func init(_target: PathFollow2D, _damage: float):
	target = _target
	damage = _damage

func _physics_process(delta):
	if not is_instance_valid(target) or not target.alive:
		queue_free()
		return
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta

# Use area_entered to detect the enemy's hitbox
func _on_area_entered(area: Area2D):
	# area is the enemy's HitBox; its parent is the enemy PathFollow2D
	var body = area.get_parent()
	if body == target:
		target.take_damage(damage)
		queue_free()
