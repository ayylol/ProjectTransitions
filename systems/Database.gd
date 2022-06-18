extends Node

var _module_name
var _module_content
var _flags
var _edited_flags := []

func load_flags():
	# Loading flags
	var file = File.new()
	file.open("res://content/flags.json", file.READ)
	var content = file.get_as_text()
	_flags = parse_json(content)
	file.close()
	
func load_module(module_name : String):
	_module_name = module_name 
	# Load content
	var file = File.new()
	file.open("res://content/" + module_name + "_content.json", file.READ)
	var content = file.get_as_text()
	_module_content = parse_json(content)
	file.close()

	
func eval(flag_name : String):
	var negate = false
	if flag_name.begins_with("!"):
		negate = true
		flag_name = flag_name.trim_prefix("!")
	var flag = _flags[flag_name]
	var val
	if typeof(flag) == TYPE_BOOL:
		val = flag if not flag_name in _edited_flags else not flag
	else:
		val = true
		for and_flag in flag:
			var and_clause_value = false
			for or_flag in and_flag:
				if eval(or_flag):
					and_clause_value = true
					break
			if not and_clause_value:
				val = false
				break
	return val if not negate else !val

func change(flag_name, value):
	var default_flag = _flags[flag_name]
	if typeof(default_flag) == TYPE_BOOL:
		if flag_name in _edited_flags and value == default_flag:
			_edited_flags.erase(flag_name)
		elif not flag_name in _edited_flags and value != _flags[flag_name]:
			_edited_flags.append(flag_name)
	else:
		print("can't change the value of non-atomic flag")

# Wrapper function for returning text + their choices
func get(title : String):
	var content = _module_content[title]
	if "effect" in content:
		for key in content["effect"]:
			change(key, content["effect"][key])
	# get list of available choices
	var choices = []
	for choice in content["choices"]:
		if typeof(choice) == TYPE_DICTIONARY:
			if eval(choice["flag"]):
				choices.append(choice["choice"])
		else:
			choices.append(choice)
	
	var data = {
		"text" : content["text"],
		"choices" : choices
	}
	return data
