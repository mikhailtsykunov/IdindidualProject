
# game_manager.gd (autoload)
extends Node

signal gold_changed(new_amount: int)
signal lives_changed(new_amount: int)

var gold: int = 100:
	set(value):
		gold = value
		emit_signal("gold_changed", gold)
var lives: int = 20:
	set(value):
		lives = value
		emit_signal("lives_changed", lives)
		if lives <= 0:
			game_over()

func add_gold(amount: int):
	gold += amount

func lose_life(amount: int = 1):
	lives -= amount

func can_afford(cost: int) -> bool:
	return gold >= cost

func spend(cost: int):
	gold -= cost

func game_over():
	get_tree().paused = true
	# Show game over screen (you can implement this)
