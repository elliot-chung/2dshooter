extends Node3D

const ROUND_ENEMY := preload("res://Enemies/RoundEnemy.tscn")
const ROUND_PAUSE := 3.0
const ENEMY_SPAWN_PAUSE := 5.0

@export var PlayerPath := NodePath()
@export var InventoryPath := NodePath()

var Player: CharacterBody3D
var Inventory: Control
var SelectionScreen: Control

var round_concluded: bool
var pause_timer: float
var enemy_spawn_timer: float
var live_enemies: int

var spawn_queue: Array

func _handle_enemy_health_change(value: float, change: float):
	if value > 0.0 :
		pass
	else:
		live_enemies -= 1	

func _spawn_enemies():
	var max_enemies := 10 if spawn_queue.size() > 10 else spawn_queue.size()
	var n_to_spawn := (Global.round_number - 2) / 4
	n_to_spawn += 3
	n_to_spawn = clamp(n_to_spawn, 3, max_enemies)
	
	for _i in range(n_to_spawn):
		var resource: Resource = spawn_queue.pop_front()
		var rand_angle := randf() * 2 * PI
		var rand_length: float = lerp(25.0, 50.0, randf())
		
		var rand_vector := Vector3(1,0,0).rotated(Vector3.UP, rand_angle) * rand_length
		
		var spawn_coord: Vector3 = Player.get_global_transform().origin + rand_vector
		spawn_coord.x = clamp(spawn_coord.x, -145, 145)
		spawn_coord.z = clamp(spawn_coord.z, -145, 145)
		var enemy: CharacterBody3D = resource.instantiate()
		enemy.set_global_position(spawn_coord)
		$Player.connect("position_changed", Callable(enemy, "set_max_speed_towards_position"))
		get_node("/root/").add_child(enemy)
		enemy.connect("health_changed",Callable(self,"_handle_enemy_health_change"))
		live_enemies += 1
	

func _populate_spawn_queue():
	var round_enemies := []
	round_enemies.resize(1 + 2 * Global.round_number)
	round_enemies.fill(ROUND_ENEMY)
	
	spawn_queue.append_array(round_enemies)
	spawn_queue.shuffle()
	
func _change_to_gameover():
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")

func _ready():
	Player = get_node(PlayerPath)
	Player.connect("player_died", _change_to_gameover)
	
	Inventory = get_node(InventoryPath)
	
	Inventory.connect("stat_changed",Callable(Player,"handle_stat_change"))
	
	SelectionScreen = Inventory.get_node("SelectionScreen")
	SelectionScreen.connect("powerup_selected",Callable(self,"_handle_powerup_selection"))
	
	round_concluded = false
	pause_timer = 0.0
	enemy_spawn_timer = ENEMY_SPAWN_PAUSE
	Global.round_number = 1
	live_enemies = 0
	
	$RoundCount.text = str(Global.round_number)
	_populate_spawn_queue()

func _handle_powerup_selection(rarity: String, power_name: String):
	get_tree().paused = false
	SelectionScreen.hide()
	Inventory.add_stack(rarity, power_name)
	Inventory.set_player_variables()
	Player.refresh()
	
	$RoundCount.text = str(Global.round_number)
	
	_populate_spawn_queue()
	pause_timer = 0.0
	round_concluded = false

func _process(delta):
	if round_concluded:
		pause_timer += delta
	else:
		enemy_spawn_timer += delta
	
	if pause_timer > ROUND_PAUSE:
		get_tree().paused = true
		SelectionScreen.show()
	
	if enemy_spawn_timer > ENEMY_SPAWN_PAUSE:
		_spawn_enemies()
		enemy_spawn_timer = 0.0
	
	if !round_concluded && spawn_queue.size() == 0 && live_enemies == 0:
		round_concluded = true
		Global.round_number += 1
		
