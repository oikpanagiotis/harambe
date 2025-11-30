extends CharacterBody3D

var player: CharacterBody3D = null
@export var player_node: NodePath
@onready var nav_agent = $NavigationAgent3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var offset_x
var offset_y

func _ready():
	player = get_node(player_node)
	offset_x = randf_range(-10.0, 10.0)
	offset_y = randf_range(-10.0, 10.0)
	
func _physics_process(delta: float) -> void:
	var player_position = player.global_transform.origin
	nav_agent.target_position.x = player_position.x + offset_x
	nav_agent.target_position.z = player_position.z + offset_y
	var next_agent_position = nav_agent.get_next_path_position()
	var direction = (next_agent_position - global_transform.origin).normalized()
	
	velocity = direction * SPEED
	
	look_at(player_position)
	
	move_and_slide()
