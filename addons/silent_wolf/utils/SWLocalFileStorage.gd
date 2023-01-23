extends Node

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd") 

# Retrieves data stored as JSON in local storage
# example path: "user://swsession.save"

# store lookup (not logged in player name) and validator in local file
static func save_data(path: String, data: Dictionary, debug_message: String='Saving data to file in local storage: ') -> void:
	var local_file = FileAccess.open(path, FileAccess.WRITE)
	SWLogger.debug(debug_message + str(data))
	local_file.store_line(JSON.new().stringify(data))
	local_file.close()


static func remove_data(path: String, debug_message: String='Removing data from file in local storage: ') -> void:
	var local_file = FileAccess.open(path, FileAccess.WRITE)
	var data = {}
	SWLogger.debug(debug_message + str(data))
	local_file.store_line(JSON.new().stringify(data))
	local_file.close()



static func get_data(path: String) -> Dictionary:
	var return_data = {}
	if FileAccess.file_exists(path):
		var local_file = FileAccess.open(path, FileAccess.WRITE)
		var test_json_conv = JSON.new()
		test_json_conv.parse(local_file.get_as_text())
		var data = test_json_conv.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			return_data = data
		else:
			SWLogger.debug("Invalid data in local storage")
	else:
		SWLogger.debug("Could not find any data at: " + str(path))
	return return_data
