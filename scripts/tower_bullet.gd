extends Node2D

@export var damage = 5
@export var fire_rate = 1.0
@export var attack_range = 200.0

var bullet_scene = preload("res://Scenes/bullet.tscn")
var target = null
var enemies_in_range = []
@export var is_ghost = false

func _ready():
	if is_ghost:
		# Если это призрак — выключаем ему логику
		set_process(false) # Отключает поворот
		$ShootTimer.stop() # Выключает стрельбу
		$Area2D.monitoring = false # Чтобы не искал врагов
		return 
		
	$ShootTimer.start()
	# Настройка радиуса (убедитесь, что у Area2D есть CollisionShape2D с CircleShape)
	if $Area2D/CollisionShape2D.shape is CircleShape2D:
		$Area2D/CollisionShape2D.shape.radius = attack_range
	
	# Подключаем сигналы для Area2D (важно для Godot 4!)
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.area_exited.connect(_on_area_exited)

func _process(_delta):
	# Если есть цель, поворачиваемся к ней
	if is_instance_valid(target):
		look_at(target.global_position) # Башня "смотрит" на врага
	else:
		update_target()

func _on_area_entered(area):
	# Проверяем группу у самого вошедшего объекта ИЛИ у его родителя
	if area.is_in_group("enemies") or area.get_parent().is_in_group("enemies"):
		enemies_in_range.append(area)
		update_target()


func _on_area_exited(area):
	enemies_in_range.erase(area)
	if target == area:
		target = null
		update_target()

func update_target():
	if target == null and enemies_in_range.size() > 0:
		# Выбираем первого врага из тех, кто в зоне
		var candidate = enemies_in_range[0]
		if is_instance_valid(candidate):
			target = candidate

func _on_shoot_timer_timeout():
	if is_instance_valid(target):
		print("Башня: Стреляю!") # Если этот текст есть в консоли, а пуль нет - проблема ниже
		shoot()

func shoot():
	# 1. Проверяем, что сцена пули вообще загружена
	if bullet_scene == null:
		print("Ошибка: Сцена пули не найдена!")
		return
		
	var b = bullet_scene.instantiate()
	
	# 2. Передаем данные пуле
	b.target = target
	b.damage = damage
	
	# 3. Устанавливаем позицию (лучше использовать Marker2D на кончике дула)
	if has_node("Marker2D"):
		b.global_position = $Marker2D.global_position
	else:
		b.global_position = global_position
		
	# 4. Добавляем на карту
	get_tree().current_scene.add_child(b)
