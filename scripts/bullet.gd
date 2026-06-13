extends Area2D

var speed = 600.0
var target = null
var damage = 0

func _process(delta: float) -> void:
	# 1. Если цель исчезла, пуля удаляется
	if not is_instance_valid(target):
		queue_free()
		return
	
	# 2. Движение к цели
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# 3. Поворот пули по направлению полета
	rotation = direction.angle()
	
	# 4. ПРОВЕРКА ПОПАДАНИЯ (тот самый блок, который выдавал ошибку)
	if global_position.distance_to(target.global_position) < 15:
		# Проверяем у самого таргета
		if target.has_method("take_damage"):
			target.take_damage(damage)
		# Если скрипт висит на родителе (PathFollow2D), проверяем и там
		elif target.get_parent().has_method("take_damage"):
			target.get_parent().take_damage(damage)
			
		print("Пуля попала! Урон: ", damage)
		queue_free() # Пуля исчезает ПОСЛЕ нанесения урона
