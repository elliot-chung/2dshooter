extends Node3D

const ENEMY := preload("res://Enemies/RoundEnemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_5:
			var enemy := ENEMY.instantiate()
			enemy.transform = global_transform
			get_node("/root/").add_child(enemy)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
