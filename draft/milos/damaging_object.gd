extends Node
@onready var damageArea = $"../DamageArea"
@onready var rigidBody = $".."
func _ready():
	damageArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if is_moving() && body.is_in_group("enemies"):
		body.get_node("Health").take_damage(90)

func is_moving(threshold: float = 0.01) -> bool:
	return rigidBody.linear_velocity.length() > threshold
