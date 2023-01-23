extends Camera3D

const LIMIT := 147.0

@export var PlayerPath := NodePath()

var Player: CharacterBody3D
var offset := Vector3(0.0, 0.0, 0.0)

func _ready():
	Player = get_node(PlayerPath)
	var player_pos := Player.get_global_position()
	var cam_pos := self.get_global_position()
	offset = cam_pos - player_pos
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_pos := Player.get_global_position() + offset
	var clamp_x := clamp(new_pos.x, -LIMIT, LIMIT)
	var clamp_z := clamp(new_pos.z, -LIMIT, LIMIT)
	
	new_pos.x = clamp_x
	new_pos.z = clamp_z
	self.set_global_position(new_pos)
