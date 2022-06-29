extends Control

var topic := "intro"
var choices = []
signal goto_adventure

var _module_name
var _module_content
var _flags
var _edited_flags := []

func _ready():
	#GameState.load_game()
	#load_flags("flags")
	#load_module("module1")
	load_flags("test_flags")
	load_module("test")
	update_menu(topic)

func update_menu(label):
	topic = label
	var data = get(label)
	$VBoxContainer/HBoxContainer/RichTextLabel.bbcode_text = data["text"]
	choices = data["choices"]
	var i = 0
	for b in $VBoxContainer/GridContainer.get_children():
		if i < choices.size():
			var text = (
				choices[i] if typeof(choices[i]) == TYPE_STRING 
				else choices[i]["label"] if not "text" in choices[i] 
				else choices[i]["text"])
			b.text = text
			b.show()
		else:
			b.hide()
		i+=1

func _on_Button_button_down(extra_arg_0):
	if typeof(choices[extra_arg_0]) == TYPE_STRING:
		update_menu(choices[extra_arg_0])
	else:
		update_menu(choices[extra_arg_0]["label"])
	GameState.save_game()

func _on_Back_Button_button_down():
	emit_signal("goto_adventure")
	
func save_state():
	var save_dict = {
		"topic" : topic,
		"edited_flags" : _edited_flags
	}
	return save_dict

func load_state(state_dict):
	topic = state_dict["topic"]
	_edited_flags = state_dict["edited_flags"]

func load_flags(flags_file_name : String):
	# Loading flags
	var file = File.new()
	file.open("res://content/" + flags_file_name + ".json", file.READ)
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
		val = false
		for or_clause in flag:
			var or_clause_value = true
			for and_clause in or_clause:
				if not eval(and_clause):
					or_clause_value = false
					break
			if or_clause_value:
				val = true
				break
	return val if not negate else !val

func change(flag_name, value):
	if typeof(_flags[flag_name]) == TYPE_BOOL:
		var bool_val
		if typeof(value) == TYPE_BOOL:
			bool_val = value
		else:
			bool_val = eval(value)
		if flag_name in _edited_flags and bool_val == _flags[flag_name]:
			_edited_flags.erase(flag_name)
		elif not flag_name in _edited_flags and bool_val != _flags[flag_name]:
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
		if typeof(choice) == TYPE_DICTIONARY and "flag" in choice:
			if eval(choice["flag"]):
				choices.append(choice)
		else:
			choices.append(choice)
	
	var data = {
		"text" : content["text"],
		"choices" : choices
	}
	return data
