extends Node

var _module_content
var _module_flags

func _ready():
	load_module("module1")

func load_module(module_name : String):
	# Load content
	var file = File.new()
	file.open("res://content/" + module_name + "_content.json", file.READ)
	var content = file.get_as_text()
	_module_content = parse_json(content)
	file.close()
	# Loading flags
	file.open("res://content/" + module_name + "_flags.json", file.READ)
	content = file.get_as_text()
	_module_flags = parse_json(content)
	file.close()
	
func eval(flag_name : String):
	var flag = _module_flags[flag_name]
	if typeof(flag) == TYPE_BOOL:
		return flag
	var val = true
	for and_flag in flag:
		var and_clause_value = false
		for or_flag in and_flag:
			if eval(or_flag):
				and_clause_value = true
				break
		if not and_clause_value:
			val = false
			break
	return val

# Wrapper function for returning text + their choices
func get(title : String):
	# TODO: do flag checking edit text according to rules
	var choices = []
	for choice in _module_content[title]["choices"]:
		if typeof(choice) == TYPE_DICTIONARY:
			if eval(choice["flag"]):
				choices.append(choice["choice"])
		else:
			choices.append(choice)
		
	var data = {
		"text" : _module_content[title]["text"],
		"choices" : choices
	}
	return data
