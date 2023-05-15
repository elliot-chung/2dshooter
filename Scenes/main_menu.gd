extends Control


func _start_game():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	
func _load_leaderboard_page():
	get_tree().change_scene_to_file("res://Scenes/leaderboard.tscn")


func _ready():
	$MenuButtons/PlayButton.connect("pressed", _start_game)
	$MenuButtons/LeaderboardButton.connect("pressed", _load_leaderboard_page)

