extends Node

var _module_content
var _module_flags

func _ready():
	load_module("module1")
	
 
func load_module(module_name : String):
	var file = File.new()
	file.open("res://content/" + module_name + "_content.json", file.READ)
	var content = file.get_as_text()
	_module_content = parse_json(content)

func get_text(title : String):
	return _module_content[title]["text"]
	
func get_choice(title : String, index : int):
	return _module_content[title]["choices"][index]
