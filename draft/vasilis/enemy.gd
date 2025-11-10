extends CharacterBody3D

var player: CharacterBody3D = null
@export var player_node: NodePath
@onready var nav_agent = $NavigationAgent3D

const SPEED = 2.0
const JUMP_VELOCITY = 4.5


func _ready():
	player = get_node(player_node)
	
	
func _physics_process(delta: float) -> void:
	var player_position = player.global_transform.origin
	nav_agent.target_position = player_position
	var next_agent_position = nav_agent.get_next_path_position()
	var direction = (next_agent_position - global_transform.origin).normalized()
	
	velocity = direction * SPEED
	
	look_at(player_position)
	
	move_and_slide()
