extends CharacterBody3D

signal enemy_health_changed(value, change)
signal enemy_died()

const KNOCKBACK := 10.0
const ACCELERATION := 2.0

const AUDIO_PLAYER := preload("res://sound effects/soundplayer.tscn")

const HIT_AUDIO := preload("res://sound effects/enemy_hit.wav")

# Exported Variables
@export var starting_damage: float = 10.0
@export var starting_movement_speed: float = 5.0
@export var starting_max_health: float = 10.0

@export var damage_scale: float = 1.2
@export var movement_speed_scale: float = 1.1
@export var max_health_scale: float = 1.2

@export var round_scaling: bool = true

# Public Variables
var max_speed := Vector3()
var health := starting_max_health

# Private Variables
var _gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

var _damage = starting_damage
var _movement_speed = starting_movement_speed
var _max_health = starting_max_health

func true_hit(damage:float, knockback:Vector3, real_bullet:bool=true):
	health -= damage
	velocity += knockback
	
	var player = AUDIO_PLAYER.instantiate()
	player.stream = HIT_AUDIO
	player.global_transform = global_transform
	get_node("/root/").add_child(player)
	
	if damage == 0: return
	emit_signal("enemy_health_changed", health, -damage)
	
	if is_queued_for_deletion(): return
	if health <= 0:
		health = 0
		emit_signal("enemy_died")
		queue_free()
	


func set_max_speed_towards_position(position: Vector3):
	# Move Towards Player
	var currPos := get_global_transform().origin
	
	var direction := (position - currPos)
	direction.y = 0
	direction = direction.normalized()
	
	max_speed = direction * _movement_speed
	
func _check_collisions():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider == null: # Fix for non-deterministic bug, idk 
			pass
		elif collider.get_collision_layer_value(3): # Colliding with Player
			collider.take_damage(_damage, -collision.get_normal() * KNOCKBACK, true)
# Called when the node enters the scene tree for the first time.
func _ready():
	if round_scaling:
		var scale_factor = Global.round_number - 10 if Global.round_number > 10 else 0
		_damage = starting_damage *(damage_scale**scale_factor)
		_movement_speed = starting_movement_speed *(movement_speed_scale**scale_factor)
		_max_health = starting_max_health *(max_health_scale**scale_factor)
		health = _max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_check_collisions()
	
	velocity = velocity.lerp(max_speed, delta * ACCELERATION)
	
	if !self.is_on_floor():
		velocity.y += _gravity * delta
	
	
	move_and_slide()
	
