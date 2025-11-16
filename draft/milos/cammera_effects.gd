extends Camera3D

var time_left: float = 0.0
var trauma_decay: float = 1.5
var shake_power: float = 0.1

func screen_shake(amount: float):
	time_left = clamp(time_left + amount, 0.0, 1.0)

func _process(delta):
	if time_left > 0:
		var shake = pow(time_left, 2)
		rotation.x = randf() * shake_power * shake
		rotation.y = randf() * shake_power * shake
		rotation.z = randf() * shake_power * shake
		time_left = max(time_left - trauma_decay * delta, 0)
	else:
		rotation = Vector3.ZERO
