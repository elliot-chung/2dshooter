extends Node

signal stat_changed(stat_name, value)


@export var ItemListPath := NodePath()
@export var ButtonPath := NodePath()


var PowerupList: ItemList
var ShowStatsButton: TextureButton

var item_dictionary = {
	"common": {
		"healthy": {
			"count": 0,
			"description": "Increases max health"
		},
		"sturdy": {
			"count": 0,
			"description": "Reduces damage and knockback taken"
		},
		"lonely": {
			"count": 0,
			"description": "Increases projectile knockback"
		},
		"satiated": {
			"count": 0,
			"description": "Increases health regeneration"
		},
		"deadly": {
			"count": 0,
			"description": "Increases projectile damage"
		},
		"precise": {
			"count": 0,
			"description": "Increases critical hit chance"
		},
		"zippy": {
			"count": 0,
			"description": "Increases projectile speed and damage"
		},
		"slowpoke": {
			"count": 0,
			"description": "Decreases projectile speed and increases damage"
		},
		"bigger": {
			"count": 0,
			"description": "Increases projectile size and damage"
		},
		"trigger_happy": {
			"count": 0,
			"description": "Increases projectile rate of fire"
		},
		"faster": {
			"count": 0,
			"description": "Increases movement speed"
		},
		"impatient": {
			"count": 0,
			"description": "Decreases dash cooldown"
		},
		"masochistic": {
			"count": 0,
			"description": "Regenerate health after taking damage"
		},
		"volatile": {
			"count": 0,
			"description": "Increases projectile damage and knockback"
		}
	},
	"rare": {
		"volatile": {
			"count": 0,
			"description": "Explode when hit by a melee attack"
		},
		"vampiric": {
			"count": 0,
			"description": "Firing costs health but heal from damage"
		},
		"procrastinator": {
			"count": 0,
			"description": "A portion of damage is taken over time instead"
		},
		"frugal": {
			"count": 0,
			"description": "Increase dash count by 1"
		},
		"homing": {
			"count": 0,
			"description": "Projectiles release a homing projectile on hit"
		},
		"explosive": {
			"count": 0,
			"description": "Projectiles explode on hit"
		},
		"rhythmic": {
			"count": 0,
			"description": "Increase base rate of fire"
		},
		"bouncy": {
			"count": 0,
			"description": "Projectiles bounce off walls"
		},
	},
	"legendary": {
		"immune": {
			"count": 0,
			"description": "Gain a shield that blocks the next instance of damage"
		},
		"instantaneous": {
			"count": 0,
			"description": "Replace dash with a teleport"
		},
		"persistent": {
			"count": 0,
			"description": "Projectiles bounce towards another enemy on hit"
		},
		"undying": {
			"count": 0,
			"description": "When you would die, come back with 20% health"
		}
	}
}

func _calculate_stacks_capped(n: int, starting_multiplier: float, maximum: int) -> float:
	n = min(n, maximum)
	return n * starting_multiplier

func _calculate_stacks_linear(n: int, starting_multiplier: float, ending_multiplier: float, dropoff_start: int, dropoff_end: int) -> float:
	var output := 0.0
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
	var output := 0.0
	var reduced_stacks: int = max(n - dropoff_start, 0)
	var unreduced_stacks := n - reduced_stacks 
	output += unreduced_stacks * starting_multiplier
	output += starting_multiplier * (1 - pow(0.5, unreduced_stacks))
	return output

func _calculate_multiplier(stat_name: String, n: int) -> float:
	match stat_name:
		"health_scaling":
			return 1.0 + _calculate_stacks_linear(n, 0.25, 0.15, 10, 15)
		"damage_mitigation":
			return _calculate_stacks_log(n, 0.1, 6)
		"knockback_mitigation":
			return _calculate_stacks_capped(n, 0.1, 10)
		"movement_speed_scaling":
			return 1.0 + _calculate_stacks_linear(n, 0.25, 0.1, 10, 15)
		_:
			return 1.0

func set_player_variables():
	for rarity in item_dictionary:
		for key in item_dictionary[rarity]: 
			var count: int = item_dictionary[rarity][key].count
			if count <= 0:
				continue
			match key:
				"healthy":
					emit_signal("stat_changed", "health_scaling", _calculate_multiplier("health_scaling", count))
				"sturdy":
					emit_signal("stat_changed", "damage_mitigation", _calculate_multiplier("damage_mitigation", count))
					emit_signal("stat_changed", "knockback_mitigation", _calculate_multiplier("knockback_mitigation", count))
				"faster":
					emit_signal("stat_changed", "movement_speed_scaling", _calculate_multiplier("movement_speed_scaling", count))
				_:
					pass

func _toggle_stat_screen(toggle):
	if toggle:
		$StatScreen.show()
	else:
		$StatScreen.hide()		

func add_stack(rarity: String, power_name: String):
	var sub_dict:Dictionary = item_dictionary[rarity]
	sub_dict[power_name].count += 1

func _ready():
	PowerupList = get_node(ItemListPath)
	ShowStatsButton = get_node(ButtonPath)
	
	ShowStatsButton.connect("toggled",Callable(self,"_toggle_stat_screen"))



