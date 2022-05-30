extends Node

var _module_content

func _ready():
	var file = File.new()
	file.open("res://content.json", file.READ)
	
	var content = file.get_as_text()
	_module_content = parse_json(content)
 
func get_text(title):
	return _module_content[title]["text"]
	
func get_choice(title, index):
	return _module_content[title]["choices"][index]
