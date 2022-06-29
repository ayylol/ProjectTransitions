extends Control

signal goto_adventure

export var text_speed = 0.01

var topic := "intro"
var choices = []

var _module_name
var _module_content
var _flags
var _edited_flags := []

onready var dialogue_box = $VBoxContainer/HBoxContainer/RichTextLabel
onready var options = $VBoxContainer/Options
onready var timer = $Timer

func _ready():
	timer.wait_time = text_speed
	
func start():
	GameState.load_game()
	load_flags("test_flags")
	load_module("test")
	update_menu(topic)

func update_menu(label : String):
	topic = label
	var data = get(label)
	dialogue_box.bbcode_text = data["text"]
	dialogue_box.visible_characters = 0
	choices = data["choices"]
	var i = 0
	for b in options.get_children():
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
		timer.start()

func _on_Button_button_down(extra_arg_0 : int):
	if typeof(choices[extra_arg_0]) == TYPE_STRING:
		update_menu(choices[extra_arg_0])
	else:
		update_menu(choices[extra_arg_0]["label"])
	GameState.save_game()

func _on_Back_Button_button_down():
	emit_signal("goto_adventure")

func eval(flag_name : String) -> bool:
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

#Value should either be a type or a string corresponding to a flag to evaluate
func change_flag(flag_name : String, value):
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

func get(title : String) -> Dictionary:
	var content = _module_content[title]
	if "effect" in content:
		for key in content["effect"]:
			change_flag(key, content["effect"][key])
	# get list of available choices
	var available_choices = []
	for choice in content["choices"]:
		if typeof(choice) == TYPE_DICTIONARY and "flag" in choice:
			if eval(choice["flag"]):
				available_choices.append(choice)
		else:
			available_choices.append(choice)
	
	var data = {
		"text" : content["text"],
		"choices" : available_choices
	}
	return data

func save_state() -> Dictionary:
	var save_dict = {
		"topic" : topic,
		"edited_flags" : _edited_flags
	}
	return save_dict

func load_state(state_dict : Dictionary):
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


func _on_Timer_timeout():
	print("new character")
	dialogue_box.visible_characters += 1
	if not dialogue_box.visible_characters >= dialogue_box.bbcode_text.length():
		timer.start()
