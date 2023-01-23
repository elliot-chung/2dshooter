extends Control


func _start_game():
	get_tree().change_scene_to_file("res://Scenes/Test Scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuButtons/PlayButton.connect("pressed", _start_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
