extends Node3D

# ---------------------------------------------------------
# Resources
# ---------------------------------------------------------
var cloud_particles := preload("res://draft/milos/particles/cloud.tscn")

# ---------------------------------------------------------
# Nodes
# ---------------------------------------------------------
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

@onready var hitbox_left: Area3D  = $ArmatureLeft/Skeleton3D/BoneAttachment3D/Area3D
@onready var hitbox_right: Area3D = $ArmatureRight/Skeleton3D/BoneAttachment3D/Area3D
@onready var ground_pound_hitbox: Area3D = $GroundPountHitbox

@onready var cam     = $"../Camera3D"
@onready var particles = $"../../../BaseParticleSpawner"

var prev_hand_pos_left: Vector3
var prev_hand_pos_right: Vector3

var hand_velocity_left: Vector3
var hand_velocity_right: Vector3

var bodies_already_hit_in_swing := []

func _ready():
	_set_idle(true)
	
	hitbox_left.body_entered.connect(_on_body_entered_left)
	hitbox_right.body_entered.connect(_on_body_entered_right)

	hitbox_left.monitoring = false
	hitbox_right.monitoring = false

func _physics_process(delta):
	hand_velocity_left  = _update_hand_velocity(hitbox_left,  prev_hand_pos_left,  delta)
	hand_velocity_right = _update_hand_velocity(hitbox_right, prev_hand_pos_right, delta)

func _update_hand_velocity(hitbox: Area3D, prev_pos: Vector3, delta: float) -> Vector3:
	var new_pos = hitbox.global_position
	var vel = (new_pos - prev_pos) / max(delta, 0.00001)
	prev_pos = new_pos
	return vel

func _set_idle(on: bool):
	animation_tree["parameters/conditions/is_idle"] = on

func _set_swiping(on: bool):
	animation_tree["parameters/conditions/is_swiping"] = on

func _set_stop_swinging(on: bool):
	animation_tree["parameters/conditions/stop_swinging"] = on

func _set_ground_pounding(on: bool):
	animation_tree["parameters/conditions/is_ground_pounding"] = on

func _set_ground_pound_end(on: bool):
	animation_tree["parameters/conditions/is_ground_pound_end"] = on

# =========== ACTIONS =======================================
func swing():
	_set_swiping(true)
	_set_idle(false)
	_set_ground_pounding(false)

func jump():
	_set_swiping(false)
	_set_idle(false)
	_set_ground_pounding(false)
	_set_ground_pound_end(false)

func start_ground_pound():
	_set_swiping(false)
	_set_idle(false)
	_set_ground_pounding(true)

func smash():
	cam.screen_shake(2)
	particles.spawn_wall_jump_particles()

	_set_swiping(false)
	_set_idle(true)
	_set_ground_pounding(false)

	for body in ground_pound_hitbox.get_overlapping_bodies():
		if body.is_in_group("object"):
			var dir = (body.global_position - ground_pound_hitbox.global_position).normalized()
			body.apply_impulse(dir * 20.0)


func stop_swinging():
	_set_swiping(false)
	_set_stop_swinging(true)
	
func are_swinging() -> bool:
	return animation_tree["parameters/conditions/is_swiping"]

func are_doing_ground_pound() -> bool:
	return animation_tree["parameters/conditions/is_ground_pounding"]

func are_smashing() -> bool:
	return playback.get_current_node() == "Ground Pound Smash"



# ============= PARTICLES =================================
func _spawn_hit_cloud(pos: Vector3):
	var cloud := cloud_particles.instantiate()
	cloud.global_position = pos
	get_tree().current_scene.add_child(cloud)

	var p = cloud.get_node("Cloud")
	p.emitting = true
	p.one_shot = true
	p.connect("finished", cloud.queue_free)


# =============== COMBAT ===================================

func _handle_hit(body: Node3D, hitbox: Area3D, vel: Vector3):
	if body in bodies_already_hit_in_swing:
		return

	if body.is_in_group("enemies"):
		bodies_already_hit_in_swing.append(body)
		_spawn_hit_cloud(hitbox.global_position)
		cam.screen_shake(0.7)
		return

	if body.is_in_group("object") and body is RigidBody3D:
		bodies_already_hit_in_swing.append(body)

		var dir = (body.global_position - hitbox.global_position).normalized()
		var impulse = dir * vel.length() * 0.1
		body.apply_impulse(impulse)

		_spawn_hit_cloud(hitbox.global_position)
		cam.screen_shake(0.5)

# =============== SIGNALS ===================================

func _on_body_entered_left(body):
	_handle_hit(body, hitbox_left, hand_velocity_left)

func _on_body_entered_right(body):
	_handle_hit(body, hitbox_right, hand_velocity_right)

# ==================== HITBOX ==============================

func activate_puch_hitbox_left():
	bodies_already_hit_in_swing.clear()
	hitbox_left.monitoring = true

func deactivate_puch_hitbox_left():
	hitbox_left.monitoring = false

func activate_puch_hitbox_right():
	bodies_already_hit_in_swing.clear()
	hitbox_right.monitoring = true

func deactivate_puch_hitbox_right():
	hitbox_right.monitoring = false
