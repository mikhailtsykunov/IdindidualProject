extends Node2D

# --- Глобальные переменные ---
@onready var upgrade_menu = $CanvasLayer/UI/UpgradeMenu

var money = 100
var lives = 20
var wave = 0
var mobs_left = 0
var wave_mobs = [1, 2, 3]
var wave_speed = [1.0, 0.8, 0.6, 0.4, 0.2]
var occupied_cells = [] # Массив для хранения координат занятых клеток

var current_tower_scene = null 
var ghost_tower = null 
var tile_size = 64 

# --- Ресурсы ---
var enemy = preload("res://Scenes/enemy.tscn")
var tower = preload("res://Scenes/towerBullet.tscn")
var laser = preload("res://Scenes/towerZapper.tscn")
var bank = preload("res://Scenes/towerBank.tscn")

var game_won = false
var game_over = false

func _ready():
	# Скрываем панели, чтобы они не блокировали клики мыши во время игры
	$CanvasLayer/UI/PanelGameOver.visible = false
	$CanvasLayer/UI/PanelWin.visible = false
	
	# Ваша старая логика таймера волны
	$TimerWave.wait_time = 2.0
	$TimerWave.start()


func _process(_delta: float) -> void:
	# Обновление UI
	$CanvasLayer/UI/Label.text = "Cash: " + str(money)
	if has_node("CanvasLayer/UI/LivesLabel"):
		$CanvasLayer/UI/LivesLabel.text = "Lives: " + str(lives)
	
	# Логика "призрака" башни
	if ghost_tower:
		ghost_tower.global_position = snap_to_grid(get_global_mouse_position())
		
	# Обновление текста и доступности кнопок в меню улучшения (если оно открыто)
	if upgrade_menu and upgrade_menu.visible:
		upgrade_menu.update_ui_text()


func _physics_process(_delta: float) -> void:
	# Приоритет проигрыша
	if game_over:
		$CanvasLayer/UI/PanelGameOver.visible = true
		$CanvasLayer/UI/PanelWin.visible = false
		return 

	# Условие победы
	if wave >= wave_mobs.size() and $Path2D.get_child_count() == 0:
		if lives > 0 and not game_won:
			game_won = true
			$CanvasLayer/UI/PanelWin.visible = true
			$CanvasLayer/UI/PanelGameOver.visible = false
			get_tree().paused = true

func _input(event):
	# Отмена выбора на правую кнопку
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_build()

	# Постройка или вызов меню на левую кнопку
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# ПРОВЕРКА: Если клик был по кнопке UI или любому другому элементу интерфейса
		# то прекращаем выполнение кода, чтобы не сбивать фокус с меню
		if upgrade_menu and upgrade_menu.visible:
			# Проверяем, находится ли курсор физически над границами меню
			# Если да — отдаем приоритет кнопкам UI и выходим
			if upgrade_menu.get_global_rect().has_point(get_global_mouse_position()):
				return 

		# РЕЖИМ СТРОИТЕЛЬСТВА
		if current_tower_scene and money >= 25:
			if is_mouse_in_build_zone():
				place_tower()
		# РЕЖИМ ВЫЗОВА МЕНЮ (если ничего не строим)
		else:
			try_upgrade_tower_at_mouse()



func place_tower():
	var target_pos = snap_to_grid(get_global_mouse_position())
	
	# ПРОВЕРКА: Если эта клетка уже в списке занятых — выходим из функции
	if target_pos in occupied_cells:
		print("Клетка занята!")
		return 

	var new_tower = current_tower_scene.instantiate()
	new_tower.global_position = target_pos
	add_child(new_tower)
	
	# Добавляем позицию в список занятых
	occupied_cells.append(target_pos)
	
	# Подключаем сигнал для банка (если есть)
	if new_tower.has_signal("money_generated"):
		new_tower.money_generated.connect(_on_bank_generated_money)
	
	money -= 25
	cancel_build()

func cancel_build():
	current_tower_scene = null
	if ghost_tower:
		ghost_tower.queue_free()
		ghost_tower = null
		
	# Закрываем меню улучшения при отмене строительного режима или нажатии ПКМ
	if upgrade_menu:
		upgrade_menu.visible = false
		upgrade_menu.selected_tower = null


func snap_to_grid(pos: Vector2) -> Vector2:
	var s = Vector2(tile_size, tile_size)
	return (pos / s).floor() * s + s / 2.0

func is_mouse_in_build_zone() -> bool:
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	var results = space_state.intersect_point(params)
	for result in results:
		if result.collider.is_in_group("build_zone"):
			return true
	return false

func take_damage(amount):
	if game_over or game_won: return
	lives -= amount
	if lives <= 0:
		lives = 0
		game_over = true
		$CanvasLayer/UI/PanelGameOver.visible = true
		get_tree().paused = true

func _on_enemy_died(amount):
	money += amount
	
func _on_bank_generated_money(amount):
	money += amount
	print("Банк принес доход: ", amount, ". Всего: ", money)

# --- Логика Волн ---

func _on_timer_wave_timeout() -> void:
	if wave < wave_mobs.size() and not game_over:
		mobs_left = wave_mobs[wave] 
		$TimerEnemy.wait_time = wave_speed[wave]
		$TimerEnemy.start()

func _on_timer_enemy_timeout() -> void:
	if game_over or game_won or mobs_left <= 0:
		$TimerEnemy.stop()
		return

	# Спавн
	var instance = enemy.instantiate()
	$Path2D.add_child(instance)
	
	# Подключаем сигнал денег
	if instance.has_signal("died"):
		instance.died.connect(_on_enemy_died)
	
	mobs_left -= 1
	
	if mobs_left <= 0:
		$TimerEnemy.stop()
		wave += 1
		if wave < wave_mobs.size():
			$TimerWave.start()

# --- Кнопки UI (Покупка башен) ---

func _on_texture_button_tower_1_pressed(): prepare_ghost(laser)
func _on_texture_button_tower_2_pressed(): prepare_ghost(tower)
func _on_texture_button_tower_3_pressed(): prepare_ghost(bank)

func prepare_ghost(tower_scene):
	if ghost_tower: ghost_tower.queue_free()
	current_tower_scene = tower_scene
	ghost_tower = tower_scene.instantiate()
	
	# Отключаем функционал у призрака
	if ghost_tower.has_node("ShootTimer"):
		ghost_tower.get_node("ShootTimer").stop()
	if ghost_tower.has_node("Area2D"):
		ghost_tower.get_node("Area2D").monitoring = false
	
	ghost_tower.modulate.a = 0.5
	add_child(ghost_tower)

# --- Кнопки на экранах Победы и Поражения ---

# Сигнал от ButtonRestart на панели ПОБЕДЫ или ПОРАЖЕНИЯ

func _on_button_restart_pressed() -> void:
	get_tree().paused = false 
	get_tree().reload_current_scene() 

func _on_button_menu_pressed() -> void:
	get_tree().paused = false 
	
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	if "main2" in current_scene_path:
		GameManager.unlock_level("main3")
	elif "main" in current_scene_path:
		GameManager.unlock_level("main2")
	
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")

func _on_button_menu_2_pressed() -> void:
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")

func try_upgrade_tower_at_mouse():
	var mouse_grid_pos = snap_to_grid(get_global_mouse_position())
	
	if mouse_grid_pos in occupied_cells:
		for child in get_children():
			if child is Node2D and child.global_position == mouse_grid_pos:
				var upgrader = child.get_node_or_null("TowerUpgrader")
				if upgrader:
					# Используем нашу переменную, созданную на Шаге 2
					if upgrade_menu:
						upgrade_menu.open_for_tower(child)
				break
	else:
		# Если кликнули по пустой земле — скрываем меню
		if upgrade_menu and upgrade_menu.visible:
			upgrade_menu.visible = false
			upgrade_menu.selected_tower = null


	
