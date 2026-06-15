extends Control

@onready var upgrade_button: Button = $UpgradeButton
@onready var sell_button: Button = $SellButton
@onready var close_button: Button = $CloseButton


var selected_tower: Node2D = null
var main_script: Node2D = null

func _ready() -> void:
	visible = false
	main_script = get_tree().current_scene

func open_for_tower(tower_node: Node2D) -> void:
	selected_tower = tower_node
	visible = true
	
	# Смещаем меню чуть в сторону от башни
	global_position = tower_node.global_position + Vector2(40, -80)
	update_ui_text()

func update_ui_text() -> void:
	if not selected_tower or not main_script: return
	
	var upgrader = selected_tower.get_node_or_null("TowerUpgrader")
	if upgrader:
		var current_lvl = upgrader.current_level
		var cost = upgrader.get_upgrade_cost()
		
		# Настройка текста и доступности кнопки Улучшения
		if cost == -1:
			upgrade_button.text = "Макс. Ур."
			upgrade_button.disabled = true
		else:
			upgrade_button.text = "Улучшить: " + str(cost)
			# Кнопка активна, только если у игрока хватает денег
			upgrade_button.disabled = main_script.money < cost
			
		# Настройка текста кнопки Продажи (возвращаем 50% от стоимости)
		var current_stats = upgrader.levels[current_lvl]
		var sell_price = int((25 + current_stats["cost"]) * 0.5)
		sell_button.text = "Продать: +" + str(sell_price)


# Эту функцию нужно связать через вкладку Узел -> Сигналы -> pressed()
func _on_upgrade_button_pressed() -> void:
	if not selected_tower: return
	
	var upgrader = selected_tower.get_node_or_null("TowerUpgrader")
	if upgrader and upgrader.can_upgrade(main_script.money):
		var cost = upgrader.get_upgrade_cost()
		
		main_script.money -= cost
		upgrader.upgrade()
		
		update_ui_text()
		print("Успешное улучшение башни!")

# Эту функцию нужно связать через вкладку Узел -> Сигналы -> pressed()
func _on_sell_button_pressed() -> void:
	if not selected_tower or not main_script: return
	
	var upgrader = selected_tower.get_node_or_null("TowerUpgrader")
	if upgrader:
		var current_lvl = upgrader.current_level
		var current_stats = upgrader.levels[current_lvl]
		var sell_price = int((25 + current_stats["cost"]) * 0.5)
		
		main_script.money += sell_price
		
		var tower_pos = selected_tower.global_position
		if tower_pos in main_script.occupied_cells:
			main_script.occupied_cells.erase(tower_pos)
			
		selected_tower.queue_free()
		_on_close_button_pressed()
		print("Башня успешно продана!")

# Эту функцию нужно связать через вкладку Узел -> Сигналы -> pressed()
func _on_close_button_pressed() -> void:
	visible = false
	selected_tower = null
