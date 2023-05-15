extends CharacterBody3D

const DAMAGE := 2.5
const MAX_SPEED := 20.0
const ACCELERATION := 0.5
const ARMING_TIME := 0.5

@export var HomingAreaPath := NodePath()

var HomingArea: Area3D
var direction := Vector3.ZERO
var speed := 0.0

var _time_til_armed := ARMING_TIME

func _ready():
	HomingArea = get_node(HomingAreaPath)
	velocity = direction * speed
	
func _physics_process(delta):
	var overlapping_bodies := HomingArea.get_overlapping_bodies()
	var closest_enemy: CharacterBody3D = overlapping_bodies.reduce(_by_distance)
	
	var target_vector := (closest_enemy.global_position - global_position).normalized() * MAX_SPEED if closest_enemy != null else direction * MAX_SPEED
	
	velocity = velocity.lerp(target_vector, delta * ACCELERATION)
	direction = velocity.normalized()
	var collision = move_and_collide(velocity * delta)
	
	if _time_til_armed > 0.0:
		_time_til_armed -= delta	
		return
	
	if collision == null:
		return
		
	var collider: CollisionObject3D = collision.get_collider()
	if collider.get_collision_layer_value(4): # Colliding with enemy
		collider.true_hit(DAMAGE, Vector3.ZERO, false)
		queue_free()
	
	

func _by_distance(closest, current): 
	var dist_to_closest = closest.global_position.distance_to(global_position)
	var dist_to_current = current.global_position.distance_to(global_position)
	return closest if dist_to_closest < dist_to_current else current
