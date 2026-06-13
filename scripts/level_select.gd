extends Control

# Находим кнопку второго уровня внутри контейнера
@onready var btn_lvl_2 = $VBoxContainer/GridContainer/ButtonLevel2  # если скрипт на VBoxContainer

func _ready() -> void:
	# Проверяем доступность уровня в глобальном менеджере при запуске экрана
	btn_lvl_2.disabled = !GameManager.unlocked_levels["main2"]

# Сигнал от кнопки ButtonLevel1
func _on_button_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# Сигнал от кнопки ButtonLevel2
func _on_button_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main2.tscn")

# Сигнал от кнопки ButtonLevel3 (на будущее)
func _on_button_level_3_pressed() -> void:
	pass # Здесь будет загрузка третьего уровня, когда вы его создадите

# Сигнал от кнопки BackButton для возврата в меню
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn") # Укажите точный путь к вашей сцене меню
