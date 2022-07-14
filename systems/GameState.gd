extends Node

# THIS NEEDS TO CHANGE TO BE MORE MODULAR

func save_game():
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	var nodes_to_save = $"../Camera/UI".get_tree().get_nodes_in_group("Persist")
	for node in nodes_to_save:
		if node.filename.empty():
			print("'%s' is not an instanced scene, skipping", node.name)
			continue
		if !node.has_method("save_state"):
			print("'%s' is missing save_state() function, skipping", node.name)
			continue
		#print("saving data from ", node.name)
		var to_save = node.call("save_state")
		to_save["path"] = node.get_path()
		save_file.store_line(to_json(to_save))
	save_file.close()

func load_game():
	var save_file = File.new()
	if not save_file.file_exists("user://savegame.save"):
		print("no save game file")
		return # No saved game
	
	save_file.open("user://savegame.save", File.READ)
	while not save_file.eof_reached():
		var data = JSON.parse(save_file.get_line()).result
		if not typeof(data) == TYPE_DICTIONARY:
			continue
		var node = $"../Game".get_node(data["path"])
		if !node.has_method("load_state"):
			print("'%s' is missing load_state() function, skipping", node.name)
			continue
		node.call("load_state", data)
	save_file.close()
