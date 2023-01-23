extends Control


func _start_game():
	get_tree().change_scene_to_file("res://Scenes/Test Scene.tscn")


func _ready():
	$MenuButtons/PlayButton.connect("pressed", _start_game)

