extends Control

enum State {
	IDLE,
	SHOW_TEXT,
	SHOW_OPTIONS,
	HIDE_OPTIONS,
}
var state = State.IDLE

signal goto_adventure

export var text_speed := 0.75
export var options_size := 1.0
export var options_delta_size := 0.1

var topic := "intro"
var choices := []
var character := ""
var emotion := ""

var _module_name
var _module_content
var _flags
var _edited_flags := []

var _visible_char_float := 0.0
var _current_options_size := 0.0

onready var dialogue_box = $VBoxContainer/HBoxContainer/TextBox/RichTextLabel
onready var continue_indicator = $VBoxContainer/HBoxContainer/TextBox/ContinueIndicator
onready var dialogue_box_button = $VBoxContainer/HBoxContainer/TextBox/TextButton
onready var options = $VBoxContainer/Options

func _ready():
	set_process(false)
	
func start():
	#GameState.load_game()
	load_flags("test_flags")
	load_module("test")
	update_menu(topic)

func update_menu(label : String):
	topic = label
	#Check for correct formating
	assert(label in _module_content, "label not in module")
	var content = _module_content[label]
	assert("text" in content, "No text in label")
	assert("choices" in content, "No choices in label")
	
	if "effect" in content:
		for key in content["effect"]:
			change_flag(key, content["effect"][key])
	
	# get list of available choices
	choices.clear()
	for choice in content["choices"]:
		if typeof(choice) == TYPE_DICTIONARY and "flag" in choice:
			if eval(choice["flag"]):
				choices.append(choice)
		else:
			choices.append(choice)
	dialogue_box.bbcode_text = "[color=#474920]" + content["text"] + "[/color]"
	#dialogue_box.bbcode_text = content["text"]
	
	var update_portraits = false
	if "character" in content:
		character = content["character"]
		update_portraits = true
	if "emotion" in content:
		emotion = content["emotion"]
		update_portraits = true
	if update_portraits:
		update_portraits()
	
	_visible_char_float = 0.0
	dialogue_box.visible_characters = _visible_char_float		
	state = State.HIDE_OPTIONS
	set_process(true)

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

func update_portraits():
	var path_to_portrait = "res://resources/portraits/"+character+"/"+emotion+".png"
	var directory = Directory.new();
	assert(not directory.dir_exists(path_to_portrait), path_to_portrait + " does not exist")
	var sprite = load(path_to_portrait)
	$VBoxContainer/MainCharacter.texture = sprite

# GAME STATE FUNCTIONS
func save_state() -> Dictionary:
	var save_dict = {
		"topic" : topic,
		"edited_flags" : _edited_flags
	}
	return save_dict

func load_state(state_dict : Dictionary):
	topic = state_dict["topic"]
	_edited_flags = state_dict["edited_flags"]
# END OF GAME STATE FUNCTIONS

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

func _process(delta):
	#TODO: Change to use tweens for option growing/shrinking
	match state:
		State.IDLE:
			set_process(false)
		State.SHOW_TEXT:
			_visible_char_float += text_speed
			dialogue_box.visible_characters = round(_visible_char_float)
			if dialogue_box.visible_characters > dialogue_box.text.length():
				state = State.SHOW_OPTIONS
		State.SHOW_OPTIONS:
			if not options.visible:
				if "text" in choices[0] and choices[0]["text"] == "next":
					dialogue_box_button.show()
					continue_indicator.show()
					return
				options.show()
				var i = 0
				for o in choices:
					var text = (
							choices[i] if typeof(choices[i]) == TYPE_STRING 
							else choices[i]["label"] if not "text" in choices[i] 
							else choices[i]["text"])
					var button = options.get_child(i)
					button.text = text
					button.show()
					i+=1
				options.size_flags_stretch_ratio = 0.0
			else:
				options.size_flags_stretch_ratio += options_delta_size
				if options.size_flags_stretch_ratio >= options_size:
					state = State.IDLE
		State.HIDE_OPTIONS:
			if continue_indicator.visible:
				continue_indicator.hide()
				dialogue_box_button.hide()
				state = State.SHOW_TEXT
			elif options.visible:
				options.size_flags_stretch_ratio -= options_delta_size
				if options.size_flags_stretch_ratio <= 0.0:
					for b in options.get_children():
						b.hide()
					options.hide()
					state = State.SHOW_TEXT
			else:
				state = State.SHOW_TEXT
				continue_indicator.hide()
		_:
			state = State.IDLE
			set_process(false)


func _on_TextButton_pressed():
	update_menu(choices[0]["label"])
