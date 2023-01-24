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

func _calculate_stacks_uncapped(n: int, multiplier: float) -> float:
	return n * multiplier

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
		"healthy_health_scaling":
			return _calculate_stacks_linear(n, 0.25, 0.15, 10, 15)
		"sturdy_damage_mitigation":
			return _calculate_stacks_log(n, 0.1, 6)
		"sturdy_knockback_mitigation":
			return _calculate_stacks_capped(n, 0.1, 10)
		"lonely_projectile_knockback":
			return _calculate_stacks_linear(n, .1, .5, 10, 15)
		"satiated_health_regen":
			return _calculate_stacks_uncapped(n, 1.0)
		"deadly_damage_scaling":
			return _calculate_stacks_linear(n, 0.25, 0.15, 10, 15)
		"precise_critical_chance":
			return _calculate_stacks_capped(n, 0.1, 10)
		"zippy_damage_scaling":
			return _calculate_stacks_uncapped(n, 0.1)
		"zippy_projectile_speed_scaling":
			return _calculate_stacks_linear(n, 0.20, 0.05, 10, 15)
		"slowpoke_projectile_speed_scaling":
			return _calculate_stacks_capped(n, -0.2, 4)
		"slowpoke_damage_scaling":
			return _calculate_stacks_linear(n, 0.45, 0.25, 10, 15)
		"faster_movement_speed_scaling":
			return _calculate_stacks_linear(n, 0.25, 0.1, 10, 15)
		"trigger_finger_firerate_scaling":
			return _calculate_stacks_linear(n, 0.25, 0.1, 10, 15)
		"impacient_dash_cooldown_scaling":
			return _calculate_stacks_log(n, -0.1, 7)
		_:
			return 0.0

func set_player_variables():
	var new_health_scaling: float = 1.0
	var new_damage_mitigation: float = 0.0
	var new_knockback_mitigation: float = 0.0
	var new_projectile_knockback: float = 1.0
	var new_health_regen: float = 0.0
	var new_damage_scaling: float = 1.0
	var new_critical_chance: float = 0.0
	var new_projectile_speed_scaling: float = 1.0
	var new_projectile_size: float = 1.0
	var new_firerate_scaling: float = 1.0
	var new_movement_speed_scaling: float = 1.0
	var new_dash_cooldown_scaling: float = 1.0
	

	for rarity in item_dictionary:
		for key in item_dictionary[rarity]: 
			var count: int = item_dictionary[rarity][key].count
			if count <= 0:
				continue
			match key:
				"healthy":
					new_health_scaling += _calculate_multiplier("healthy_health_scaling", count)
				"sturdy":
					new_damage_mitigation += _calculate_multiplier("sturdy_damage_mitigation", count)
					new_knockback_mitigation += _calculate_multiplier("sturdy_knockback_mitigation", count)
				"lonely":
					new_projectile_knockback += _calculate_multiplier("lonely_projectile_knockback", count)
				"satiated":
					new_health_regen += _calculate_multiplier("satiated_health_regen", count)
				"deadly":
					new_damage_scaling += _calculate_multiplier("deadly_damage_scaling", count)
				"precise":
					new_critical_chance += _calculate_multiplier("precise_critical_chance", count)
				"zippy":
					new_damage_scaling += _calculate_multiplier("zippy_damage_scaling", count)
					new_projectile_speed_scaling += _calculate_multiplier("zippy_projectile_speed_scaling", count)
				"slowpoke":
					new_damage_scaling += _calculate_multiplier("slowpoke_damage_scaling", count)
					new_projectile_speed_scaling += _calculate_multiplier("slowpoke_projectile_speed_scaling", count)
				"bigger":
					new_damage_scaling += _calculate_multiplier("bigger_damage_scaling", count)
					new_projectile_size += _calculate_multiplier("bigger_projectile_size", count)
				"trigger_happy":
					new_firerate_scaling += _calculate_multiplier("trigger_happy_firerate_scaling", count)
				"faster":
					new_movement_speed_scaling += _calculate_multiplier("faster_movement_speed_scaling", count)
				"impatient":
					new_dash_cooldown_scaling += _calculate_multiplier("impatient_dash_cooldown_scaling", count)
				_:
					pass
	
	emit_signal("stat_changed", "health_scaling", new_health_scaling)
	emit_signal("stat_changed", "damage_mitigation", new_damage_mitigation)
	emit_signal("stat_changed", "knockback_mitigation", new_knockback_mitigation)
	emit_signal("stat_changed", "projectile_knockback", new_projectile_knockback)
	emit_signal("stat_changed", "health_regen", new_health_regen)
	emit_signal("stat_changed", "damage_scaling", new_damage_scaling)
	emit_signal("stat_changed", "critical_chance", new_critical_chance)
	emit_signal("stat_changed", "projectile_speed_scaling", new_projectile_speed_scaling)
	emit_signal("stat_changed", "projectile_size", new_projectile_size)
	emit_signal("stat_changed", "firerate_scaling", new_firerate_scaling)
	emit_signal("stat_changed", "movement_speed_scaling", new_movement_speed_scaling)
	emit_signal("stat_changed", "dash_cooldown_scaling", new_dash_cooldown_scaling)

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



