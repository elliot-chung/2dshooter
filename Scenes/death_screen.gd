extends Control


func _restart_game():
	get_tree().change_scene_to_file("res://Scenes/Test Scene.tscn")

func _exit_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/Score.text = "Round " + ("%03d" % Global.round_number)
	$Menu/PlayAgainButton.connect("pressed", _restart_game)
	$Menu/ExitButton.connect("pressed", _exit_to_main_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
