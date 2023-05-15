extends CharacterBody3D

signal player_died
signal position_changed(position)

const AUDIO_PLAYER := preload("res://sound effects/soundplayer.tscn")

const BULLET := preload("res://Projectiles/Bullet.tscn")
const BULLET_AUDIO := preload("res://sound effects/player_shoot.wav")
const EXPLOSION_AUDIO := preload("res://sound effects/player_explode.wav")
const DASH_AUDIO := preload("res://sound effects/dash.wav")
const HIT_AUDIO := preload("res://sound effects/player_hit.wav")

const BASE_DASH_COOLDOWN := 5.0
const DASH_LENGTH := 0.05
const DASH_SPEED := 4.0
const INVINCIBILITY_TIME := 0.25
const REGEN_TIME := 0.5
const PAYBACK_COOLDOWN := 5.0
const PAYBACK_KNOCKBACK_STRENGTH := 20.0
const DOT_DAMAGE_RATE := 20.0

@export var PlayerPath: NodePath = NodePath()
@export var CameraPath: NodePath = NodePath()
@export var MeshInstancePath: NodePath = NodePath()
@export var BulletLocationPath: NodePath = NodePath()
@export var ExplosionEffectPath: NodePath = NodePath()
@export var ExplosionRadiusPath: NodePath = NodePath()

# Configurable Variables
@export var movement_speed: float = 3.0				# Movement Values
@export var movement_speed_scaling: float = 1.0

@export var projectile_speed: float = 15.0			# Projectile Values
@export var projectile_speed_scaling: float = 1.0
@export var fire_rate: float = 1.0 # RPS
@export var fire_rate_scaling: float = 1.0
@export var projectile_size: float = 1.0
@export var projectile_knockback: float = 1.0
@export var max_wall_bounces: int = 0
@export var max_enemy_bounces: int = 0
@export var firing_cost: float = 0.0
@export var heatseeker_count: int = 0
@export var explosion_conversion: float = 0.0

@export var dash_cooldown_scaling: float = 1.0		# Dash Values
@export var max_dash_count: int = 1

@export var base_health: float = 100.0 				# Health Values
@export var health_scaling: float = 1.0
@export var health_regen: float = 0.0
@export var comeback_regen: float = 0.0
@export var lifesteal: float = 0.0

@export var damage_mitigation: float = 0.0			# Damage Mitigation Values
@export var knockback_mitigation: float = 0.0
@export var dot_conversion: float = 0.0

@export var base_damage: float = 5.0 				# Damage Values
@export var damage_scaling: float = 1.0
@export var critical_chance: float = 0.0
	
@export var melee_payback_damage: float = 0.0   # Melee Payback Values

# Nodes
var Player: CharacterBody3D
var PlayerCamera: Camera3D
var PlayerMeshInstance: MeshInstance3D
var BulletLocation: Node3D
var ExplosionEffect: CPUParticles3D
var ExplosionRadius: Area3D

# Public Variables
var max_speed := Vector3()              # Target movement vector
var movement := Vector3()               # Horizonal movement vector
var speed := Vector3()                  # Actual movement vector
var current_vertical_speed := Vector3() # Vertical movement vector
var max_health := base_health * health_scaling
var health := max_health
var dash_count := max_dash_count
var dashing := false
var dead := false

# Internal Variables
var _bullet_position := Vector3()
var _facing_direction := Vector3()
var _collision_point := Vector3()
var _gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")
var _acceleration := 3.0
var _deacceleration := 5.0
var _from := Vector3()
var _to := Vector3()
var _time_to_refire := 0.0
var _dash_timers := []
var _dash_speed := Vector3()
var _dash_time := 0.0
var _regen_timer := 0.0
var _damage_timer := 0.0
var _payback_timer := 0.0
var _time_between_shots := 1.0/(fire_rate * fire_rate_scaling)
var _queued_dot_damage := 0.0


func refresh():
	var health_percentage := health / max_health
	max_health = base_health * health_scaling
	health = max_health * health_percentage
	
	dash_count = max_dash_count
	_dash_timers.resize(max_dash_count)
	_dash_timers.fill(0.0)
	
	_time_between_shots = 1.0/(fire_rate * fire_rate_scaling)

func heal_damage(damage: float):
	health += damage
	if health > max_health:
		health = max_health
		
	$HealthBar.value = 100.0 * health / max_health

func _dot_damage(delta: float):
	if _queued_dot_damage == 0:
		return
	var damage := delta * DOT_DAMAGE_RATE
	damage = min(_queued_dot_damage, damage)
	
	_queued_dot_damage -= damage
	health -= damage

func take_damage(damage: float, knockback: Vector3, melee: bool):
	if damage != 0:
		if melee:
			if _damage_timer > 0: return
			_damage_timer = INVINCIBILITY_TIME
		_regen_timer = REGEN_TIME
		var mitigated_damage = damage * (1 - damage_mitigation)
		_queued_dot_damage += dot_conversion * mitigated_damage
		health -= (1 - dot_conversion) * mitigated_damage
		
		var player = AUDIO_PLAYER.instantiate()
		player.stream = HIT_AUDIO
		self.add_child(player)
	
		PlayerCamera.shake(0.25)
	
	if melee && melee_payback_damage > 0 && _payback_timer == 0.0: 
		explode()
		_payback_timer = PAYBACK_COOLDOWN
	else:	 
		speed += knockback * (1 - knockback_mitigation)
	if health <= 0:
		dead = true
		emit_signal("player_died")

			
			
	$HealthBar.value = 100.0 * health / max_health

func explode():
	var player = AUDIO_PLAYER.instantiate()
	player.stream = EXPLOSION_AUDIO
	self.add_child(player)
	
	ExplosionEffect.restart()
	var enemies := ExplosionRadius.get_overlapping_bodies()
	for enemy in enemies:
		var knockback := (enemy.global_position - global_position).normalized() * PAYBACK_KNOCKBACK_STRENGTH
		enemy.true_hit(melee_payback_damage, knockback, false)

func _rotate_player():	
	# Rotate Player Model _towards Cursor
	PlayerMeshInstance.look_at(_collision_point,Vector3.UP)
	var rotationDegree = PlayerMeshInstance.get_rotation_degrees()
	rotationDegree.x = 0
	rotationDegree.y += 180
	rotationDegree.z = 0
	PlayerMeshInstance.set_rotation_degrees(rotationDegree)
	
	_facing_direction = (_collision_point - PlayerMeshInstance.get_global_transform().origin)
	_facing_direction.y = 0
	_facing_direction = _facing_direction.normalized()
	_bullet_position = PlayerMeshInstance.get_global_transform().origin + 1.5 * _facing_direction

func _poll_character_movement(delta):
	emit_signal("position_changed", self.get_global_transform().origin)
	#movement
	var direction := Vector3.ZERO
	if(Input.is_action_pressed("move_up")):
		direction += Vector3(0.0,0.0,-1.0)
		# print("up")
	if(Input.is_action_pressed("move_back")):
		direction += Vector3(0.0,0.0,1.0)
		# print("back") 
	if(Input.is_action_pressed("move_left")):
		direction += Vector3(-1.0,0.0,0.0)
		# print("left")
	if(Input.is_action_pressed("move_right")):
		direction += Vector3(1.0,0.0,0.0)
		# print("right")
	if (Input.is_action_just_pressed("dash")):
		if dashing || dash_count == 0:
			return
		else:
			for n in max_dash_count:
				if _dash_timers[dash_count - n - 1] == 0:
					_dash_timers[dash_count - n - 1] = BASE_DASH_COOLDOWN * dash_cooldown_scaling
					break
				else:
					continue
			_dash_speed = DASH_SPEED * max_speed
			dashing = true
			dash_count -= 1
			var player = AUDIO_PLAYER.instantiate()
			player.stream = DASH_AUDIO
			self.add_child(player)
	
	direction.y = 0
	max_speed = movement_speed * movement_speed_scaling * direction.normalized()
	
	var accel := _deacceleration
	if(direction.dot(speed) > 0):
		accel = _acceleration
	speed = speed.lerp(max_speed, delta * accel)
	if dashing:
		speed = _dash_speed
	
	movement = speed
	current_vertical_speed.y += _gravity * delta
	movement += current_vertical_speed

func handle_stat_change(stat_name: String, value):
	set(stat_name, value)

func handle_enemy_health_change(value: float, change: float):
	if change < 0: # Enemy damaged
		heal_damage(-1 * change * lifesteal)
	else: # Enemy healing
		pass

func _handle_cooldowns(delta):
	# Invincibility 
	if _damage_timer > 0.0:
		_damage_timer -= delta
	else:
		_damage_timer = 0.0
		
	# Payback
	if _payback_timer > 0.0:
		_payback_timer -= delta
	else:
		_payback_timer = 0.0
		
	# Dash
	if dashing && _dash_time < DASH_LENGTH: 
		_dash_time += delta
	else:
		_dash_time = 0.0
		dashing = false
	if dash_count < max_dash_count:
		for i in max_dash_count:
			if _dash_timers[i] == 0.0:
				continue
			_dash_timers[i] -= delta
			if _dash_timers[i] < 0.0:
				_dash_timers[i] = 0.0
				dash_count += 1
	
	# Comeback Regen			
	_regen_timer -= delta
	if _regen_timer < 0.0:
		_regen_timer = 0.0
	
	# Firing
	if _time_to_refire > 0.0:
		_time_to_refire -= delta
	else:
		_time_to_refire = 0.0

func _calculate_cursor_location():
	var cursorPos := get_viewport().get_mouse_position()
	_to = _from + PlayerCamera.project_ray_normal(cursorPos)*100
	# Cursor Ray Trace
	var space_state := get_world_3d().direct_space_state
	# use global coordinates, not local _to node
	var query := PhysicsRayQueryParameters3D.create(_from, _to, 1)
	var result := space_state.intersect_ray(query)
	if result.get("position") != null:
		_collision_point = result["position"]
	# Move Cursor _to Collision Point

func _health_regen(delta):
	var real_regen = comeback_regen + health_regen if _regen_timer > 0.0 else health_regen
	heal_damage(real_regen * delta)
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Player = get_node(PlayerPath)
	PlayerCamera = get_node(CameraPath)
	PlayerMeshInstance = get_node(MeshInstancePath)
	BulletLocation = get_node(BulletLocationPath)
	ExplosionEffect = get_node(ExplosionEffectPath)
	ExplosionRadius = get_node(ExplosionRadiusPath)
	
	$HealthBar.value = 100.0 * health / max_health
	
	_from = PlayerCamera.project_ray_origin(Vector2(0,0))
	_dash_timers.resize(max_dash_count)
	_dash_timers.fill(0.0)
	dash_count = max_dash_count
	
	_time_between_shots = 1.0/(fire_rate * fire_rate_scaling)

func _input(event):
	#Rotate Mesh with Mouse Motion
	if event is InputEventMouseMotion:
		_rotate_player()

func _handle_firing():
	if (!Input.is_action_pressed("shoot")) || _time_to_refire > 0.0:
		return
	
	_time_to_refire = _time_between_shots
	
	take_damage(firing_cost, Vector3.ZERO, false)

	var bullet := BULLET.instantiate()
	bullet.transform = BulletLocation.get_global_transform()
	bullet.max_wall_bounces = max_wall_bounces
	bullet.max_enemy_bounces = max_enemy_bounces
	bullet.projectile_speed = projectile_speed * projectile_speed_scaling
	bullet.set_scale(Vector3(projectile_size, projectile_size, projectile_size))
	bullet.direction = _facing_direction
	bullet.player_base_damage = base_damage
	bullet.player_damage_scaling = damage_scaling
	bullet.player_knockback = projectile_knockback
	bullet.critical_chance = critical_chance
	bullet.homing_spawn = heatseeker_count
	bullet.explosion_conversion = explosion_conversion
	get_node("/root/").add_child(bullet)
	
	var player = AUDIO_PLAYER.instantiate()
	player.stream = BULLET_AUDIO
	self.add_child(player)

func _physics_process(delta):
	_calculate_cursor_location()
	_poll_character_movement(delta)
	_handle_cooldowns(delta)
	
	_health_regen(delta)
	_dot_damage(delta)
	
	_handle_firing()
	
	if !dead:	
		Player.set_velocity(movement)
		Player.set_up_direction(Vector3.UP)
		Player.move_and_slide()
		movement = Player.velocity
	
	
	_bullet_position = PlayerMeshInstance.get_global_transform().origin + 0.5 * _facing_direction
	_from = PlayerCamera.project_ray_origin(Vector2(0,0))
	
	if Player.is_on_floor():
		current_vertical_speed.y = 0
