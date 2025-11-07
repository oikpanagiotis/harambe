extends Node

func _ready() -> void:
	# Example on how to attach to an event
	GameEvents.connect("game_started", Callable(self, "_on_game_started"))
	
	# Example on how to fire an event
	GameEvents.emit_signal("game_started")
	

func _on_game_started() -> void:
	print("Game started!")
