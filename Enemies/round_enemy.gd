extends CharacterBody3D

signal health_changed(value, change)

const BASE_DAMAGE := 10.0
const KNOCKBACK := 10.0

# Exported Variables
@export var PlayerPath: NodePath = NodePath()
@export var movement_speed: float = 5.0
@export var acceleration: float = 2.0
@export var max_health: float = 10.0
@export var damage_scaling: float = 1.0

# Public Variables
var speed := Vector3()
var max_speed := Vector3()
var health := max_health

# Private Variables
var _gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

func true_hit(damage:float, knockback:Vector3):
	health -= damage
	if health <= 0:
		health = 0
		emit_signal("health_changed", health, -damage)
		queue_free()
	speed = knockback


func set_max_speed_towards_position(position: Vector3):
	# Move Towards Player
	var currPos := get_global_transform().origin
	
	var direction := (position - currPos)
	direction.y = 0
	direction = direction.normalized()
	
	max_speed = direction * movement_speed
	
func _check_collisions():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider == null: # Fix for non-deterministic bug, idk 
			pass
		elif collider.get_collision_layer_value(3): # Colliding with Player
			collider.take_damage(BASE_DAMAGE * damage_scaling, -collision.get_normal() * KNOCKBACK)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_check_collisions()
	
	speed = speed.lerp(max_speed, delta * acceleration)
	
	if !self.is_on_floor():
		speed.y += _gravity * delta
	
	set_velocity(speed)
	set_up_direction(Vector3.UP)
	move_and_slide()
	speed = velocity
	
