extends Node2D

# Сигнал для передачи суммы
signal money_generated(amount: int)

@export var income: int = 10      # Сколько денег дает башня
@export var interval: float = 5.0  # Интервал (в секундах)

func _ready():
	# Создаем таймер
	var income_timer = Timer.new()
	income_timer.name = "IncomeTimer"
	
	# Настраиваем его
	add_child(income_timer) # Сначала добавляем в дерево, потом настраиваем
	income_timer.wait_time = interval
	income_timer.one_shot = false
	
	# Подключаем сигнал (синтаксис Godot 4)
	income_timer.timeout.connect(_on_income_timer_timeout)
	
	# Запускаем
	income_timer.start()
	print("Башня запущена. Интервал: ", interval)

func _on_income_timer_timeout():
	# Печатаем в консоль для проверки
	print("Башня сгенерировала: ", income)
	
	# Испускаем сигнал
	money_generated.emit(income)
