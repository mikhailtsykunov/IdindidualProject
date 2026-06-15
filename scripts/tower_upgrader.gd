class_name TowerUpgrader
extends Node

# Сигнал для UI (если захотите выводить текст)
signal upgraded(level: int)

@export_group("Параметры Уровней")
## Настройки уровней. Уровень 0 (первый элемент) — это стартовые характеристики.
@export var levels: Array[Dictionary] = [
	{
		"cost": 0,
		"damage": 10.0,
		"range": 200.0,
		"speed": 1.0,
		"money_income": 10 # Для банка
	},
	{
		"cost": 40,
		"damage": 22.0,
		"range": 260.0,
		"speed": 1.5,
		"money_income": 25
	},
	{
		"cost": 75,
		"damage": 45.0,
		"range": 320.0,
		"speed": 2.2,
		"money_income": 50
	}
]

var current_level: int = 0
@onready var tower = get_parent()

func _ready() -> void:
	await tower.ready
	apply_stats()

## Проверка доступности апгрейда
func can_upgrade(current_money: int) -> bool:
	if current_level + 1 >= levels.size():
		return false
	return current_money >= levels[current_level + 1]["cost"]

## Получить стоимость следующего уровня
func get_upgrade_cost() -> int:
	if current_level + 1 < levels.size():
		return levels[current_level + 1]["cost"]
	return -1 # Максимальный уровень

## Функция апгрейда
func upgrade() -> void:
	current_level += 1
	apply_stats()
	upgraded.emit(current_level)

## Применение характеристик к узлам именно вашей башни
func apply_stats() -> void:
	var stats = levels[current_level]
	
	# Изменяем переменные урона в самом скрипте башни (если они там есть)
	if "damage" in tower: tower.damage = stats["damage"]
	if "money_amount" in tower: tower.money_amount = stats["money_income"] # подставьте имя вашей переменной дохода банка
	
	# Ищем ShootTimer (или Timer), который вы отключали в призраке
	var timer = tower.get_node_or_null("ShootTimer")
	if not timer:
		timer = tower.get_node_or_null("Timer")
	if timer and "speed" in stats:
		timer.wait_time = 1.0 / stats["speed"]

	# Обновляем радиус зоны Area2D вашей башни
	var area = tower.get_node_or_null("Area2D")
	if area:
		var collision = area.get_node_or_null("CollisionShape2D")
		if collision and collision.shape is CircleShape2D and "range" in stats:
			collision.shape.radius = stats["range"]
