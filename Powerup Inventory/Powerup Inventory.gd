extends Node

signal stat_changed(stat_name, value)


@export var ItemListPath := NodePath()
@export var ButtonPath := NodePath()


var PowerupList: ItemList
var ShowStatsButton: TextureButton

var item_dictionary = {
	"healthy": 0, 
	"sturdy": 0, 
	"lonely": 0, 
	"satiated": 0, 
	"deadly": 0,
	"precise": 0,
	"zippy": 0,
	"slowpoke": 0,
	"bigger": 0,
	"trigger_happy": 0,
	"faster": 0,
	"impatient": 0,
	"masochistic": 0,
	"volatile": 0,
	"vampiric": 0,
	"procrastinator": 0,
	"frugal": 0,
	"homing": 0,
	"explosive": 0,
	"rhythmic": 0,
	"bouncy": 0,
	"immune": 0,
	"instantaneous": 0,
	"persistent": 0,
	"undying": 0
}

func _calculate_stacks_linear(n: int, starting_multiplier: float, ending_multiplier: float, dropoff_start: int, dropoff_end: int) -> float:
	var output := 1.0
	var middle_stacks := dropoff_end - dropoff_start
	var step := (starting_multiplier - ending_multiplier) / middle_stacks
	if n < dropoff_start: 
		output += n * starting_multiplier
	elif n < dropoff_end: 
		var reduced_n := n - dropoff_start
		output += n * starting_multiplier - step * (reduced_n * reduced_n + reduced_n)/2 
	else: 
		var reduced_n := n - dropoff_end
		output += dropoff_end * starting_multiplier - step * (middle_stacks * middle_stacks + middle_stacks)/2
		output += reduced_n * ending_multiplier
	return output

func _calculate_stacks_log(n: int, starting_multiplier: float, dropoff_start: int) -> float:
	var output := 1.0
	var reduced_stacks: int = max(n - dropoff_start, 0)
	var unreduced_stacks := n - reduced_stacks 
	output += unreduced_stacks * starting_multiplier
	output += starting_multiplier * (1 - pow(0.5, unreduced_stacks))
	return output

func _calculate_multiplier(name: String, n: int) -> float:
	match name:
		"healthy":
			return _calculate_stacks_linear(n, 0.25, 0.15, 10, 15)
		"sturdy":
			return _calculate_stacks_log(n, 0.1, 6)
		"faster":
			return _calculate_stacks_linear(n, 0.25, 0.1, 10, 15)
		_:
			return 1.0

func set_player_variables():
	for key in item_dictionary: 
		var count: int = item_dictionary[key]
		if count <= 0:
			continue
		match key:
			"healthy":
				emit_signal("stat_changed", "health_scaling", _calculate_multiplier(key, count))
			"faster":
				emit_signal("stat_changed", "movement_speed_scaling", _calculate_multiplier(key, count))
			_:
				pass

func _toggle_stat_screen(toggle):
	if toggle:
		$StatScreen.show()
	else:
		$StatScreen.hide()		

func add_stack(name: String):
	item_dictionary[name] += 1

func _ready():
	PowerupList = get_node(ItemListPath)
	ShowStatsButton = get_node(ButtonPath)
	
	ShowStatsButton.connect("toggled",Callable(self,"_toggle_stat_screen"))



