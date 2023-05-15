extends Node

signal stat_changed(stat_name, value)

var item_dictionary = {
	"common": {
		"healthy": {
			"count": 0,
			"description": "Increases max health",
			"img_path": "res://Powerups/health.png"
		},
		"sturdy": {
			"count": 0,
			"description": "Reduces damage and knockback taken",
			"img_path": "res://Powerups/defense.png"
		},
		"lonely": {
			"count": 0,
			"description": "Increases projectile knockback",
			"img_path": "res://Powerups/offense.png"
		},
		"satiated": {
			"count": 0,
			"description": "Increases health regeneration",
			"img_path": "res://Powerups/health.png"
		},
		"deadly": {
			"count": 0,
			"description": "Increases projectile damage",
			"img_path": "res://Powerups/offense.png"
		},
		"precise": {
			"count": 0,
			"description": "Increases critical hit chance",
			"img_path": "res://Powerups/offense.png"
		},
		"zippy": {
			"count": 0,
			"description": "Increases projectile speed and damage",
			"img_path": "res://Powerups/offense.png"
		},
		"slowpoke": {
			"count": 0,
			"description": "Decreases projectile speed and increases damage",
			"img_path": "res://Powerups/offense.png"
		},
		"bigger": {
			"count": 0,
			"description": "Increases projectile size and damage",
			"img_path": "res://Powerups/offense.png"
		},
		"trigger_happy": {
			"count": 0,
			"description": "Increases projectile rate of fire",
			"img_path": "res://Powerups/offense.png"
		},
		"faster": {
			"count": 0,
			"description": "Increases movement speed",
			"img_path": "res://Powerups/movement.png"
		},
		"impatient": {
			"count": 0,
			"description": "Decreases dash cooldown",
			"img_path": "res://Powerups/movement.png"
		},
		"masochistic": {
			"count": 0,
			"description": "Regenerate health after taking damage",
			"img_path": "res://Powerups/health.png"
		},
	},
	"rare": {
		"volatile": {
			"count": 0,
			"description": "Explode when hit by a melee attack",
			"img_path": "res://Powerups/defense.png"
		},
		"vampiric": {
			"count": 0,
			"description": "Firing costs health but heal from damage",
			"img_path": "res://Powerups/health.png"
		},
		"procrastinator": {
			"count": 0,
			"description": "A portion of damage is taken over time instead",
			"img_path": "res://Powerups/defense.png"
		},
		"frugal": {
			"count": 0,
			"description": "Increase dash count by 1",
			"img_path": "res://Powerups/movement.png"
		},
		"homing": {
			"count": 0,
			"description": "Projectiles release a homing projectile on hit",
			"img_path": "res://Powerups/offense.png"
		},
		"explosive": {
			"count": 0,
			"description": "Projectiles explode on hit",
			"img_path": "res://Powerups/offense.png"
		},
		"rhythmic": {
			"count": 0,
			"description": "Increase base rate of fire",
			"img_path": "res://Powerups/offense.png"
		},
		"bouncy": {
			"count": 0,
			"description": "Projectiles bounce off walls",
			"img_path": "res://Powerups/offense.png"
		},
	},
	"legendary": {
		"persistent": {
			"count": 0,
			"description": "Projectiles bounce towards another enemy on hit",
			"img_path": "res://Powerups/offense.png"
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
			return _calculate_stacks_linear(n, 0.5, 0.3, 5, 10)
		"sturdy_damage_mitigation":
			return _calculate_stacks_log(n, 0.2, 3)
		"sturdy_knockback_mitigation":
			return _calculate_stacks_capped(n, 0.1, 10)
		"lonely_projectile_knockback":
			return _calculate_stacks_linear(n, 8.0, 2.0, 5, 10)
		"satiated_health_regen":
			return _calculate_stacks_uncapped(n, 1.0)
		"deadly_damage_scaling":
			return _calculate_stacks_linear(n, 0.5, 0.2, 5, 10)
		"precise_critical_chance":
			return _calculate_stacks_capped(n, 0.25, 4)
		"zippy_damage_scaling":
			return _calculate_stacks_uncapped(n, 0.2)
		"zippy_projectile_speed_scaling":
			return _calculate_stacks_linear(n, 0.5, 0.25, 5, 10)
		"slowpoke_projectile_speed_scaling":
			return _calculate_stacks_capped(n, -0.2, 4)
		"slowpoke_damage_scaling":
			return _calculate_stacks_linear(n, 1.0, 0.5, 5, 10)
		"bigger_damage_scaling":
			return _calculate_stacks_linear(n, 0.35, 0.2, 5, 10)
		"bigger_projectile_size":
			return _calculate_stacks_capped(n, 1.0, 10)
		"faster_movement_speed_scaling":
			return _calculate_stacks_linear(n, 0.5, 0.25, 5, 10)
		"trigger_happy_firerate_scaling":
			return _calculate_stacks_linear(n, 0.5, 0.25, 5, 10)
		"impatient_dash_cooldown_scaling":
			return _calculate_stacks_log(n, -0.1, 7)
		"frugal_max_dash_count":
			return _calculate_stacks_uncapped(n, 1.0)
		"rhythmic_fire_rate":
			return _calculate_stacks_uncapped(n, 1.0)
		"bouncy_max_wall_bounces":
			return _calculate_stacks_uncapped(n, 1.0)
		"persistent_max_enemy_bounces":
			return _calculate_stacks_uncapped(n, 1.0)
		"masochistic_comeback_regen":
			return _calculate_stacks_linear(n, 10.0, 5.0, 10, 15)
		"volatile_melee_payback_damage":
			return _calculate_stacks_linear(n, 10.0, 5.0, 10, 15)
		"vampiric_firing_cost":
			return _calculate_stacks_capped(n, 1.0, 10)
		"vampiric_lifesteal":
			return _calculate_stacks_log(n, 0.1, 9)
		"procrastinator_dot_conversion":
			return _calculate_stacks_log(n, 0.075, 6)
		"homing_heatseeker_count":
			return _calculate_stacks_uncapped(n, 1.0)
		"explosive_explosion_conversion":
			return _calculate_stacks_capped(n, 0.1, 10)
		"explosive_damage_scaling":
			return _calculate_stacks_uncapped(n, 0.25)
		_:
			assert(false, "Unknown Name: " + stat_name)
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
	var new_max_dash_count: int = 1
	var new_fire_rate: float = 1.0
	var new_max_wall_bounces: int = 0
	var new_max_enemy_bounces: int = 0
	var new_comeback_regen: float = 0.0
	var new_melee_payback_damage: float = 0.0
	var new_firing_cost: float = 0.0
	var new_lifesteal: float = 0.0
	var new_dot_conversion: float = 0.0
	var new_heatseeker_count: int = 0
	var new_explosion_conversion: float = 0.0
	
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
				"frugal":
					new_max_dash_count += _calculate_multiplier("frugal_max_dash_count", count)
				"rhythmic":
					new_fire_rate += _calculate_multiplier("rhythmic_fire_rate", count)
				"bouncy":
					new_max_wall_bounces += _calculate_multiplier("bouncy_max_wall_bounces", count)
				"persistent":
					new_max_enemy_bounces += _calculate_multiplier("persistent_max_enemy_bounces", count)
				"masochistic":
					new_comeback_regen += _calculate_multiplier("masochistic_comeback_regen", count)
				"volatile":
					new_melee_payback_damage += _calculate_multiplier("volatile_melee_payback_damage", count)
				"vampiric":
					new_firing_cost += _calculate_multiplier("vampiric_firing_cost", count)
					new_lifesteal += _calculate_multiplier("vampiric_lifesteal", count)
				"procrastinator":
					new_dot_conversion += _calculate_multiplier("procrastinator_dot_conversion", count)
				"homing":
					new_heatseeker_count += _calculate_multiplier("homing_heatseeker_count", count)
				"explosive":
					new_explosion_conversion += _calculate_multiplier("explosive_explosion_conversion", count)
					new_damage_scaling += _calculate_multiplier("explosive_damage_scaling", count)
				_:
					assert(false, "Unhandled Powerup: " + key)
	
	emit_signal("stat_changed", "health_scaling", new_health_scaling)
	emit_signal("stat_changed", "damage_mitigation", new_damage_mitigation)
	emit_signal("stat_changed", "knockback_mitigation", new_knockback_mitigation)
	emit_signal("stat_changed", "projectile_knockback", new_projectile_knockback)
	emit_signal("stat_changed", "health_regen", new_health_regen)
	emit_signal("stat_changed", "damage_scaling", new_damage_scaling)
	emit_signal("stat_changed", "critical_chance", new_critical_chance)
	emit_signal("stat_changed", "projectile_speed_scaling", new_projectile_speed_scaling)
	emit_signal("stat_changed", "projectile_size", new_projectile_size)
	emit_signal("stat_changed", "fire_rate_scaling", new_firerate_scaling)
	emit_signal("stat_changed", "movement_speed_scaling", new_movement_speed_scaling)
	emit_signal("stat_changed", "dash_cooldown_scaling", new_dash_cooldown_scaling)
	emit_signal("stat_changed", "max_dash_count", new_max_dash_count)
	emit_signal("stat_changed", "fire_rate", new_fire_rate)
	emit_signal("stat_changed", "max_wall_bounces", new_max_wall_bounces)
	emit_signal("stat_changed", "max_enemy_bounces", new_max_enemy_bounces)
	emit_signal("stat_changed", "comeback_regen", new_comeback_regen)
	emit_signal("stat_changed", "melee_payback_damage", new_melee_payback_damage)
	emit_signal("stat_changed", "firing_cost", new_firing_cost)
	emit_signal("stat_changed", "lifesteal", new_lifesteal)
	emit_signal("stat_changed", "dot_conversion", new_dot_conversion)
	emit_signal("stat_changed", "explosion_conversion", new_explosion_conversion)
	emit_signal("stat_changed", "heatseeker_count", new_heatseeker_count)

func _toggle_stat_screen(toggle):
	if toggle:
		$StatScreen.show()
	else:
		$StatScreen.hide()		

func add_stack(rarity: String, power_name: String):
	var sub_dict:Dictionary = item_dictionary[rarity]
	sub_dict[power_name].count += 1

func _ready():
	pass



