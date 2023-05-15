extends Camera3D

const LIMIT := 147.0

@export var PlayerPath := NodePath()

@export var decay := 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset := Vector2(5, 5)  # Maximum shake in pixels.

var Player: CharacterBody3D
var offset := Vector3(0.0, 0.0, 0.0)

var trauma := 0.0
var trauma_power := 2

func shake(amount: float):
	trauma = min(trauma + amount, 1.0)

func _shake(delta):
	if !trauma:
		return
	trauma = max(trauma - decay * delta, 0)
	var amount = pow(trauma, trauma_power)
	h_offset = max_offset.x * amount * randf_range(-1, 1)
	v_offset = max_offset.y * amount * randf_range(-1, 1)

func _ready():
	Player = get_node(PlayerPath)
	var player_pos := Player.get_global_position()
	var cam_pos := self.get_global_position()
	offset = cam_pos - player_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_pos := Player.get_global_position() + offset
	var clamp_x = clamp(new_pos.x, -LIMIT, LIMIT)
	var clamp_z = clamp(new_pos.z, -LIMIT, LIMIT)
	
	new_pos.x = clamp_x
	new_pos.z = clamp_z
	self.set_global_position(new_pos)
	
	_shake(delta)
