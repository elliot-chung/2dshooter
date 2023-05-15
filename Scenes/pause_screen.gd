extends Control


func _exit_game():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	get_tree().paused = false
	
func _unpause_game():
	visible = false
	get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ExitButton.connect("pressed", _exit_game)
	$ContinueButton.connect("pressed", _unpause_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
