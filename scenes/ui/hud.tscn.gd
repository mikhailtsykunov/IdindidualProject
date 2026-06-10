# hud.gd
extends CanvasLayer

@onready var gold_label = $GoldLabel
@onready var lives_label = $LivesLabel

func _ready():
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	_on_gold_changed(GameManager.gold)
	_on_lives_changed(GameManager.lives)

func _on_gold_changed(value: int):
	gold_label.text = "Gold: %d" % value

func _on_lives_changed(value: int):
	lives_label.text = "Lives: %d" % value
	
func _on_arrow_tower_pressed():
	var build_manager = get_node("/root/Game/BuildManager")
	build_manager.selected_tower = preload("res://scenes/tower.tscn")
