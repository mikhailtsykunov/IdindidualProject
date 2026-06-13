extends Control

# Находим кнопки уровней внутри контейнера
@onready var btn_lvl_2 = $VBoxContainer/GridContainer/ButtonLevel2
@onready var btn_lvl_3 = $VBoxContainer/GridContainer/ButtonLevel3

func _ready() -> void:
	# Проверяем доступность уровней в глобальном менеджере при запуске экрана
	btn_lvl_2.disabled = !GameManager.unlocked_levels.get("main2", false)
	btn_lvl_3.disabled = !GameManager.unlocked_levels.get("main3", false)

# Сигнал от кнопки ButtonLevel1
func _on_button_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# Сигнал от кнопки ButtonLevel2
func _on_button_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main2.tscn")

# Сигнал от кнопки ButtonLevel3
func _on_button_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main3.tscn")  # Замените на правильный путь к сцене 3 уровня

# Сигнал от кнопки BackButton для возврата в меню
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
