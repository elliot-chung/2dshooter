extends Node

var round_number := 1

func _unhandled_input(event):
	#Quit Game
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
