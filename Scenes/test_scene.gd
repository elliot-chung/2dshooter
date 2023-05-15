extends Node3D

const ROUND_ENEMY := preload("res://Enemies/RoundEnemy.tscn")

@export var PlayerPath := NodePath()
@export var InventoryPath := NodePath()

@export var SpawnPosition: Vector3

var Player: CharacterBody3D
var Inventory: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Player = get_node(PlayerPath)
	Inventory = get_node(InventoryPath)
	# Inventory.set_player_variables()        # Comment out these two lines if testing the character controller directly
	# Player.refresh()
	pass


func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_5:
			var enemy = ROUND_ENEMY.instantiate()
			enemy.set_global_position(SpawnPosition)
			Player.connect("position_changed", Callable(enemy, "set_max_speed_towards_position"))
			get_node("/root/").add_child(enemy)
			enemy.connect("health_changed",Callable(self,"_handle_enemy_health_change"))
			enemy.connect("health_changed", Callable(Player, "handle_enemy_health_change"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
