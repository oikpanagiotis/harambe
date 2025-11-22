extends Node3D

var cloud_particles := preload("res://draft/milos/particles/cloud.tscn")

@onready var animation_tree := $AnimationTree
@onready var hitbox_left := $ArmatureLeft/Skeleton3D/BoneAttachment3D/Area3D
@onready var hitbox_right := $ArmatureRight/Skeleton3D/BoneAttachment3D/Area3D

var prev_hand_pos_left: Vector3
var hand_velocity_left: Vector3

var prev_hand_pos_right: Vector3
var hand_velocity_right: Vector3

var bodies_already_hit_in_swing = []

func _ready():
	animation_tree["parameters/conditions/is_idle"] = true
	hitbox_left.body_entered.connect(_on_body_entered_left)
	hitbox_right.body_entered.connect(_on_body_entered_right)
	hitbox_right.monitoring = false
	hitbox_left.monitoring = false

func _physics_process(delta):
	var now = hitbox_left.global_position
	hand_velocity_left = (now - prev_hand_pos_left) / delta
	prev_hand_pos_left = now
	
	now = hitbox_right.global_position
	hand_velocity_right = (now - prev_hand_pos_right) / delta
	prev_hand_pos_right = now
	
func swing():
	animation_tree["parameters/conditions/is_swiping"] = true
	animation_tree["parameters/conditions/is_idle"] = false
	
func jump():
	animation_tree["parameters/conditions/is_swiping"] = false
	animation_tree["parameters/conditions/is_idle"] = false
	
func stop_swinging():
	animation_tree["parameters/conditions/is_swiping"] = false
	animation_tree["parameters/conditions/is_idle"] = true

func are_swinging():
	return animation_tree["parameters/conditions/is_swiping"]

func _spawn_hit_cloud(global_pos: Vector3):
	var cloud := cloud_particles.instantiate()
	cloud.global_position = global_pos
	get_tree().current_scene.add_child(cloud)

	var p := cloud.get_node("Cloud")
	p.emitting = true
	p.one_shot = true
	p.connect("finished", cloud.queue_free)


func _handle_hit(body, hitbox, hand_velocity):
	if(body in bodies_already_hit_in_swing):
		return
		
	if body.is_in_group("enemies"):
		bodies_already_hit_in_swing.append(body)
		_spawn_hit_cloud(hitbox.global_position)
		$"../Camera3D".screen_shake(0.7)
	if body.is_in_group("object") and body is RigidBody3D:
		bodies_already_hit_in_swing.append(body)
		var direction = (body.global_position - hitbox.global_position).normalized()
		var impulse = direction * hand_velocity.length() * 3
		body.apply_impulse(impulse)
		_spawn_hit_cloud(hitbox.global_position)
		$"../Camera3D".screen_shake(0.5)

func _on_body_entered_left(body):
	_handle_hit(body, hitbox_left, hand_velocity_left)

func _on_body_entered_right(body):
	_handle_hit(body, hitbox_right, hand_velocity_right)

func activate_puch_hitbox_left():
	bodies_already_hit_in_swing.clear()
	hitbox_left.monitoring = true

func deactivate_puch_hitbox_left():
	hitbox_left.monitoring = false

func activate_puch_hitbox_right():
	hitbox_right.monitoring = true

func deactivate_puch_hitbox_right():
	bodies_already_hit_in_swing.clear()
	hitbox_right.monitoring = false
