extends Node

var unlocked_levels = {
	"main1": true,
	"main2": false,
	"main3": false
}

const SAVE_PATH = "user://savegame.cfg"

func _ready() -> void:
	load_progress()

func unlock_level(level_name: String) -> void:
	print("Разблокируем уровень: ", level_name)  # Для отладки
	unlocked_levels[level_name] = true
	print("Текущие разблокированные уровни: ", unlocked_levels)  # Для отладки
	save_progress()

func is_level_unlocked(level_name: String) -> bool:
	return unlocked_levels.get(level_name, false)

func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("progress", "unlocked_levels", unlocked_levels)
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		if config.has_section_key("progress", "unlocked_levels"):
			unlocked_levels = config.get_value("progress", "unlocked_levels")
