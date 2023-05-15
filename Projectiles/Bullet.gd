extends CharacterBody3D

const AUDIO_PLAYER := preload("res://sound effects/soundplayer.tscn")
const EXPLOSION_AUDIO := preload("res://sound effects/projectile_explode.wav")
const HEATSEEKER := preload("res://Projectiles/Heatseeker.tscn")
const EXPLOSION_VISUAL := preload("res://Projectiles/ExplosionVisual.tscn")
const EXPLOSION_KNOCKBACK := 10.0


@export var AreaNodePath := NodePath()
@export var ExplosionRadiusPath := NodePath()

var direction := Vector3()
var max_wall_bounces := 0
var max_enemy_bounces := 0
var projectile_speed := 0.0
var player_base_damage: float = 0.0
var player_damage_scaling: float = 0.0
var player_knockback: float = 0.0
var critical_chance: float = 0.0
var explosion_conversion: float = 0.0
var homing_spawn: int = 0

var BounceArea: Area3D
var ExplosionRadius: Area3D

var _velocity_vector := Vector3()
var _wall_bounce_count := 0 
var _enemy_bounce_count := 0
var _damage := 0.0
var _knockback := Vector3()

func _ready():
	BounceArea = get_node(AreaNodePath)
	ExplosionRadius = get_node(ExplosionRadiusPath)
	
	_damage = player_base_damage * player_damage_scaling
	var crit := randf() < critical_chance
	if crit:
		_damage *= 2
		player_knockback *= 2
	_knockback = direction * player_knockback
	
	_velocity_vector = projectile_speed * direction

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
	var _collision = move_and_collide(_velocity_vector * delta)
	if _collision != null:
		var collider: CollisionObject3D = _collision.get_collider()
		
		if collider.get_collision_layer_value(2): # Colliding with wall
			if _wall_bounce_count >= max_wall_bounces:
				queue_free()
				return

			var norm: Vector3 = _collision.get_normal()
			_velocity_vector = _velocity_vector.bounce(norm)
			direction = _velocity_vector.normalized()
			add_collision_exception_with(collider)
			_wall_bounce_count += 1
		elif collider.get_collision_layer_value(4): # Colliding with enemy
			var explosion_damage = _damage * explosion_conversion
			collider.true_hit(_damage - explosion_damage, _knockback)
			if explosion_damage: 
				var explosion_effect := EXPLOSION_VISUAL.instantiate()
				explosion_effect.global_transform = global_transform
				get_node("/root/").add_child(explosion_effect)
				explosion_effect.restart()
				
				var player = AUDIO_PLAYER.instantiate()
				player.stream = EXPLOSION_AUDIO
				player.global_transform = global_transform
				get_node("/root/").add_child(player)
				
				var enemies := ExplosionRadius.get_overlapping_bodies()
				for enemy in enemies: 
					var knockback := (enemy.global_position - global_position).normalized() * EXPLOSION_KNOCKBACK
					enemy.true_hit(explosion_damage, knockback, false)
			
			var heatseek_dir := -direction
			heatseek_dir = heatseek_dir.slerp(Vector3.UP, 0.5).normalized()
			for n in homing_spawn:
				var rand_angle_offset := randf_range(-1.0, 1.0)
				var rand_dir := heatseek_dir.rotated(Vector3.UP, rand_angle_offset)
				var heatseeker := HEATSEEKER.instantiate()
				heatseeker.transform = global_transform
				heatseeker.direction = rand_dir
				heatseeker.speed = 20.0
				get_node("/root/").add_child(heatseeker)
			if _enemy_bounce_count >= max_enemy_bounces:
				queue_free()
			else:	
				var next_enemy = _get_nearest_enemy(collider)
				if next_enemy != null:
					var next_enemy_vel: Vector3 = next_enemy.velocity
					var next_enemy_pos: Vector3 = next_enemy.get_global_transform().origin
					var curr_enemy_pos: Vector3 = collider.get_global_transform().origin
					var dir := (next_enemy_pos - curr_enemy_pos).normalized()
					var curr_pos: Vector3 = curr_enemy_pos + 1.7 * next_enemy.scale.x * dir
					self.set_global_position(curr_pos)

					_velocity_vector = projectile_speed * dir
					direction = _velocity_vector.normalized()
				_enemy_bounce_count += 1
	else:
		for body in get_collision_exceptions():
			remove_collision_exception_with(body)
