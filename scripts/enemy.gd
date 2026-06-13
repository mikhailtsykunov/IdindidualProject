extends PathFollow2D

signal died(value)

var health = 10
var reward = 10
@export var speed = 100.0

func _process(delta):
	progress += speed * delta

	if progress_ratio >= 0.99:
		# Ищем главную сцену через дерево
		var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
		
		if main.has_method("take_damage"):
			main.take_damage(1)
			print("Враг дошел! Урон нанесен.")
		else:
			print("Ошибка: Функция take_damage не найдена в Main!")
			
		queue_free()


func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	died.emit(reward) 
	queue_free()
