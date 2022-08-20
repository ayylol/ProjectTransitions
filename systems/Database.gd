extends Node

func get_content(file_path : String):
	# Load content
	var file = File.new()
	assert(file.file_exists(file_path), file_path + " does not exist.")
	file.open(file_path, file.READ)
	var text = file.get_as_text()
	var content = parse_json(text)
	file.close()
	print(content)
	return content
