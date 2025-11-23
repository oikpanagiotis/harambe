extends Node3D

var cloud_particles = preload("res://draft/milos/particles/cloud.tscn")
var landing_particles = preload("res://draft/milos/particles/landing_particles.tscn")

func spawn_wall_jump_particles():
	var particles := cloud_particles.instantiate()
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	particles.get_node("Cloud").emitting = true
	# optional auto-delete if one-shot particles
	particles.get_node("Cloud").one_shot = true
	particles.get_node("Cloud").connect("finished", particles.queue_free)

func spawn_landing_particles():
	var particles := landing_particles.instantiate()
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	particles.get_node("Cloud").emitting = true
	# optional auto-delete if one-shot particles
	particles.get_node("Cloud").one_shot = true
	particles.get_node("Cloud").connect("finished", particles.queue_free)
