extends CharacterBody3D

# const RADIAL_RAYCAST_SUBDIV = 64

# export (NodePath) var RayCastPath := NodePath()
@export var AreaNodePath := NodePath()
@export var direction := Vector3()
@export var max_wall_bounces := 0
@export var max_enemy_bounces := 0
@export var projectile_speed := 0.0
@export var player_base_damage: float = 0.0
@export var player_damage_scaling: float = 0.0
@export var player_knockback: float = 0.0
@export var critical_chance: float = 0.0

# var RayCast3D: RayCast3D
var BounceArea: Area3D

var velocity_vector := Vector3()
var wall_bounce_count := 0 
var enemy_bounce_count := 0
var damage := 0.0
var knockback := Vector3()

var _collision

func _ready():
	# RayCast3D = get_node(RayCastPath)
	BounceArea = get_node(AreaNodePath)
	
	damage = player_base_damage * player_damage_scaling
	var crit := randf() < critical_chance
	if crit:
		damage *= 2
		player_knockback *= 2
	knockback = direction * player_knockback
	
	velocity_vector = projectile_speed * direction
	
	

# func _get_nearest_enemy(ignore: Object) -> Object:
# 	RayCast3D.clear_exceptions()
# 	RayCast3D.add_exception(ignore)
# 	var deg_offset := 360.0 / RADIAL_RAYCAST_SUBDIV
# 	var min_dist := 50.0
# 	var output = null
# 	for _i in range(RADIAL_RAYCAST_SUBDIV):
# 		var cast_to:Vector3 = RayCast3D.get_target_position()
# 		cast_to = cast_to.rotated(Vector3.FORWARD, deg_to_rad(deg_offset))
# 		RayCast3D.set_target_position(cast_to)
		
# 		RayCast3D.force_raycast_update()
# 		if RayCast3D.is_colliding():
# 			var dist: float = RayCast3D.get_collision_point().distance_to(get_global_transform().origin)
# 			if dist < min_dist:
# 				min_dist = dist
# 				output = RayCast3D.get_collider() 
# 	return output

func _get_nearest_enemy(ignore: Object) -> Object:
	var output = null
	var bodies := BounceArea.get_overlapping_bodies()
	var min_dist := 50.0
	for body in bodies:
		if body == ignore:
			continue
		var dist := get_global_transform().origin.distance_to(body.get_global_transform().origin)
		if dist < min_dist:
			min_dist = dist
			output = body
	return output



func _physics_process(delta):
	_collision = move_and_collide(velocity_vector * delta)
	if _collision != null:
		var collider: CollisionObject3D = _collision.get_collider()
		
		if collider.get_collision_layer_value(2): # Colliding with wall
			if wall_bounce_count >= max_wall_bounces:
				queue_free()
				return

			var norm: Vector3 = _collision.get_normal()
			velocity_vector = velocity_vector.bounce(norm)
			direction = velocity_vector.normalized()
			add_collision_exception_with(collider)
			wall_bounce_count += 1
		elif collider.get_collision_layer_value(4): # Colliding with enemy
			if enemy_bounce_count >= max_enemy_bounces:
				queue_free()
			else:	
				var next_enemy = _get_nearest_enemy(collider)
				if next_enemy != null:
					var next_enemy_vel: Vector3 = next_enemy.speed
					var next_enemy_pos: Vector3 = next_enemy.get_global_transform().origin
					var curr_enemy_pos: Vector3 = collider.get_global_transform().origin
					var dir := (next_enemy_pos - curr_enemy_pos).normalized()
					var curr_pos: Vector3 = curr_enemy_pos + 1.7 * next_enemy.scale.x * dir
					self.set_global_position(curr_pos)

					var main_vel: float = sqrt(projectile_speed * projectile_speed - next_enemy_vel.length() * next_enemy_vel.length())
					
					if is_nan(main_vel):
						velocity_vector = projectile_speed * dir
					else:
						velocity_vector = (main_vel * dir) + next_enemy_vel
					direction = velocity_vector.normalized()
				enemy_bounce_count += 1
			collider.true_hit(damage, knockback)
	else:
		for body in get_collision_exceptions():
			remove_collision_exception_with(body)
