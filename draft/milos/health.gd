extends Node

@export var max_health: int = 100

var health: int = 100


func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	health = clamp(health - amount , 0, max_health) 
	if health == 0:
		print("Im dead")
	print(health)

func _clamp_health() -> void:
	health = clamp(health, 0, max_health)
