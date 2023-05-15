extends Control

const SCORELINE = preload("res://UIAssets/scoreline.tscn")

func _load_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$BackButton.connect("pressed", _load_main_menu)
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	$LoadingWheel.visible = false
	if sw_result["success"]:
		var scores = sw_result["scores"]
		for index in scores.size():
			var name = scores[index]["player_name"]
			var score_value = scores[index]["score"]
			var line = SCORELINE.instantiate()
			line.get_node("Name").text = str(index + 1) + " " + name
			line.get_node("Score").text = str(score_value)
			$Scoreboard.add_child(line)
	else:
		$FailureLabel.visible = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
