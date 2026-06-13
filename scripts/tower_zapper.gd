extends Node2D

@export var damage = 5
@export var fire_rate = 1.0
@export var attack_range = 200.0

var bullet_scene = preload("res://Scenes/bulletLazer.tscn")
var target = null
var enemies_in_range = []
@export var is_ghost = false

func _ready():
	if is_ghost:
		set_process(false)
		if has_node("ShootTimer"): $ShootTimer.stop()
		$Area2D.monitoring = false
		return 
	
	# 1. Настройка таймера стрельбы
	if has_node("ShootTimer"):
		$ShootTimer.wait_time = fire_rate
		# ПРОВЕРКА: Подключаем сигнал программно, если забыли в редакторе
		if not $ShootTimer.timeout.is_connected(_on_shoot_timer_timeout):
			$ShootTimer.timeout.connect(_on_shoot_timer_timeout)
		$ShootTimer.start()
	
	# 2. Настройка радиуса
	if $Area2D/CollisionShape2D.shape is CircleShape2D:
		$Area2D/CollisionShape2D.shape.radius = attack_range
	
	# 3. Подключение сигналов зоны поиска врагов
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.area_exited.connect(_on_area_exited)

func _process(_delta):
	if is_instance_valid(target):
		look_at(target.global_position)
	else:
		update_target()

func _on_area_entered(area):
	if area.is_in_group("enemies") or area.get_parent().is_in_group("enemies"):
		enemies_in_range.append(area)
		update_target()

func _on_area_exited(area):
	enemies_in_range.erase(area)
	if target == area:
		target = null
		update_target()

func update_target():
	# Очищаем список от удаленных врагов перед выбором цели
	enemies_in_range = enemies_in_range.filter(func(a): return is_instance_valid(a))
	
	if target == null and enemies_in_range.size() > 0:
		target = enemies_in_range[0]

func _on_shoot_timer_timeout():
	if is_instance_valid(target):
		shoot()

func shoot():
	if bullet_scene == null: return
		
	var b = bullet_scene.instantiate()
	b.target = target
	b.damage = damage
	
	if has_node("Marker2D"):
		b.global_position = $Marker2D.global_position
	else:
		b.global_position = global_position
		
	get_tree().current_scene.add_child(b)
