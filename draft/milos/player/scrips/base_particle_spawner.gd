extends Node3D

var cloud_particles = preload("res://draft/milos/particles/cloud.tscn")
func spawn_wall_jump_particles():
	var cloud := cloud_particles.instantiate()
	cloud.global_position = global_position
	get_tree().current_scene.add_child(cloud)
	cloud.get_node("Cloud").emitting = true
	# optional auto-delete if one-shot particles
	cloud.get_node("Cloud").one_shot = true
	cloud.get_node("Cloud").connect("finished", cloud.queue_free)
