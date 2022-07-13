extends Node

func get_content(file_path : String) -> Dictionary:
	# Load content
	var file = File.new()
	assert(file.file_exists(file_path), file_path + " does not exist.")
	file.open(file_path, file.READ)
	var content = file.get_as_text()
	var dict = parse_json(content)
	file.close()
	return dict
