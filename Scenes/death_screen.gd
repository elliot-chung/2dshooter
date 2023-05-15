extends Control


func _restart_game():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")

func _exit_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _save_score():
	var name = $Menu/NameInput.text 
	if name == "": return
	$Menu/NameInput.clear()
	$Menu/SubmitButton.disabled = true
	$Menu/SuccessLabel.visible = false
	$Menu/LoadingWheel.visible = true
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(name, Global.round_number).sw_save_score_complete
	$Menu/LoadingWheel.visible = false
	if sw_result["success"]: 
		$Menu/SuccessLabel.text = "Success"
	else: 
		$Menu/SuccessLabel.text = "Failed"
	$Menu/SuccessLabel.visible = true
	$Menu/SubmitButton.disabled = false
		

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.round_number = 19
	$Menu/Score.text = "Round " + ("%03d" % Global.round_number)
	$Menu/PlayAgainButton.connect("pressed", _restart_game)
	$Menu/ExitButton.connect("pressed", _exit_to_main_menu)
	$Menu/SubmitButton.connect("pressed", _save_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
