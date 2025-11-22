extends Node3D


@onready var player = get_parent()

@export_category("Effects")
@export var tilt: bool=true

@export_category("Tilt settings")
@export_group("Run tilt")
@export var run_pitch: float = 0.1
@export var run_roll: float = 1.0
@export var max_pitch: float = 0.1
@export var max_roll: float = 1.0


func _process(delta: float) -> void:
	calculate_view_offset(delta)

func calculate_view_offset(delta):
	var angles = Vector3.ZERO
	
	if tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		
		var forward_dot= player.velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch),deg_to_rad(max_pitch))
		angles.x  += forward_tilt
		
		var right_dot= player.velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll),deg_to_rad(max_roll))
		angles.z  -= side_tilt
	rotation = angles
