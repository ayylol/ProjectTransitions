extends Control

enum State {
	IDLE,
	SHOW_TEXT,
	SHOW_OPTIONS,
	HIDE_OPTIONS,
}
var state = State.IDLE

signal goto_adventure

export var text_speed := 100.0
export var options_size := 1.0
export var options_delta_size := 10.0

var topic := "intro"
var choices := []
var character := ""
var emotion := ""

var _module_name
var _module_content
var _flags
var _edited_flags := []
var _quiz_answers := {}

var _visible_char_float := 0.0
var _current_options_size := 0.0
var _current_option_type
var _is_audio_done := true

onready var dialogue_box = $VBoxContainer/HBoxContainer/TextBox/MarginContainer/RichTextLabel
onready var continue_indicator = $VBoxContainer/HBoxContainer/TextBox/ContinueIndicator
onready var dialogue_box_button = $VBoxContainer/HBoxContainer/TextBox/TextButton
onready var options = $VBoxContainer/Options
onready var quiz_options = $VBoxContainer/QuizOptions
onready var audio = $AudioSource

func _ready():
	set_process(false)

#TODO: Eventually make this load the correct module
func start():
	#GameState.load_game()
	load_flags("flags")
	load_module("module0")
	update_menu(topic)

func update_menu(label : String):
	var directory = Directory.new(); # For file checking
	topic = label
	# Check for correct formating
	assert(label in _module_content, "label not in module")
	var content = _module_content[label]
	assert("text" in content, "No text in label") # probably doesn't need to be asserted
	assert("choices" in content, "No choices in label") # ?
	
	if "effect" in content:
		for key in content["effect"]:
			change_flag(key, content["effect"][key])
	
	# Get list of available choices
	choices.clear()
	for choice in content["choices"]:
		if typeof(choice) == TYPE_DICTIONARY and "flag" in choice:
			if eval(choice["flag"]):
				choices.append(choice)
		else:
			choices.append(choice)
	
	# Get content to display
	var to_show = {"text": "", "audio": "", "character": "", "emotion": ""}
	get_label_vals(content, to_show)
	if "conditional" in content:
		for cond in content["conditional"].keys():
			if eval(cond):
				get_label_vals(content["conditional"][cond], to_show)
				break
	
	# Update text
	dialogue_box.bbcode_text = "[color=#474920]" + to_show["text"] + "[/color]"
	
	# Update audio
	if to_show["audio"]!="":
		var path_to_audio = "res://resources/audio/"+ _module_name + "/" + to_show["audio"] + ".ogg"
		print(path_to_audio)
		if directory.file_exists(path_to_audio):
			_is_audio_done=false
			audio.stream = load(path_to_audio)
			audio.play()
		else:
			print("No such audio file")
	
	# Update character portrait
	var update_portrait=false
	var next_character = character
	var next_emotion = emotion
	if to_show["character"]!="":
		next_character = to_show["character"]
		update_portrait=true
	if to_show["emotion"]!="":
		next_emotion = to_show["emotion"]
		update_portrait=true
	if update_portrait:
		var path_to_portrait = "res://resources/portraits/"+next_character+"/"+next_emotion+".png"
		if directory.file_exists(path_to_portrait):
			var sprite = load(path_to_portrait)
			$VBoxContainer/MainCharacter.texture = sprite
			character = next_character
			emotion = next_emotion
		else:
			print(path_to_portrait + " does not exist")
	
	_visible_char_float = 0.0
	dialogue_box.visible_characters = _visible_char_float
	state = State.HIDE_OPTIONS
	set_process(true)

func get_label_vals(input: Dictionary, to_show: Dictionary):
	if "text" in input:
		to_show["text"] = input["text"]
	if "audio" in input:
		to_show["audio"] = input["audio"]
	if "character" in input:
		to_show["character"] = input["character"]
	if "emotion" in input:
		to_show["emotion"] = input["emotion"]

func eval(command: String) -> bool:
	#Getting Variables to replace
	var parsed = command
	var regex = RegEx.new()
	regex.compile("{[A-Z]}[a-zA-Z0-9_]+")
	var m = regex.search(parsed)
	while m:
		var type = m.get_string()[1]
		var var_name = m.get_string().substr(3)
		var to_replace := ""
		match type:
			'F': # Variable is a flag
				var flag = _flags[var_name]
				if typeof(flag) == TYPE_BOOL:
					if var_name in _edited_flags:
						flag = not flag
				elif typeof(flag) == TYPE_STRING:
					flag = eval(flag)
				else:
					print("flag " + var_name + " is not a boolean nor a string")
					return false
				to_replace = String(flag).to_lower()
			'Q': # Variable is a quiz result
				var quiz_result = get_quiz_result(var_name)
				if quiz_result < 0:
					print("error with quiz: " + var_name)
					return false
				to_replace = String(quiz_result)
			_:
				print("Invalid variable type: {" + type + "}")
				return false
		parsed.erase(m.get_start(), m.get_end()-m.get_start())
		parsed = parsed.insert(m.get_start(), to_replace)
		m = regex.search(parsed)
	
	# Evaluating expression
	var expression = Expression.new()
	var error = expression.parse(parsed)
	if error != OK:
		print("Error parsing command: " + command)
		push_error(expression.get_error_text())
		return false
	var result = expression.execute()
	if not expression.has_execute_failed() and typeof(result)==TYPE_BOOL:
		return result
	print("Execution of " + command + " failed to return a boolean")
	return false

func get_quiz_result(quiz_name : String) -> float:
	if not quiz_name in _quiz_answers:
		return -1.0
	var total = 0.0
	for ans in _quiz_answers[quiz_name].values():
		total += ans
	return total/_quiz_answers[quiz_name].size()

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
	var path_to_content = "res://content/" + module_name + "_content.json"
	_module_content = Database.get_content(path_to_content)
	_module_name = module_name 

func _process(delta):
	#TODO: Change to use tweens for option growing/shrinking
	match state:
		State.IDLE:
			set_process(false)
		State.SHOW_TEXT:
			if dialogue_box.visible_characters < dialogue_box.text.length():
				_visible_char_float += text_speed * delta
				dialogue_box.visible_characters = round(_visible_char_float)
			elif _is_audio_done:
				state = State.SHOW_OPTIONS
		State.SHOW_OPTIONS: # TODO: add an option for no choices???
			if not options.visible and not quiz_options.visible:
				if "text" in choices[0] and choices[0]["text"] == "{next}":
					dialogue_box_button.show()
					continue_indicator.show()
					return
				elif "text" in choices[0] and choices[0]["text"] == "{quiz}":
					_current_option_type = quiz_options
				else:
					_current_option_type = options
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
				_current_option_type.show()
				_current_option_type.size_flags_stretch_ratio = 0.0
			else:
				_current_option_type.size_flags_stretch_ratio += options_delta_size * delta
				if _current_option_type.size_flags_stretch_ratio >= options_size:
					state = State.IDLE
		State.HIDE_OPTIONS:
			if continue_indicator.visible:
				continue_indicator.hide()
				dialogue_box_button.hide()
				state = State.SHOW_TEXT
			elif _current_option_type and _current_option_type.visible:
				_current_option_type.size_flags_stretch_ratio -= options_delta_size * delta
				if _current_option_type.size_flags_stretch_ratio <= 0.0:
					if _current_option_type == options:
						for b in options.get_children():
							b.hide()
					_current_option_type.hide()
					state = State.SHOW_TEXT
			else:
				state = State.SHOW_TEXT
				continue_indicator.hide()
		_:
			state = State.IDLE
			set_process(false)

func _on_Button_button_down(extra_arg_0 : int):
	if typeof(choices[extra_arg_0]) == TYPE_STRING:
		update_menu(choices[extra_arg_0])
	else:
		update_menu(choices[extra_arg_0]["label"])
	GameState.save_game()

func _on_quiz_button_down(extra_arg_0: int):
	var val = extra_arg_0
	var qst = choices[0]
	if qst["reversed"]:
		val = 8 - val
	if not qst["group"] in _quiz_answers:
		_quiz_answers[qst["group"]] = {}
	_quiz_answers[qst["group"]][qst["name"]] = val
	update_menu(choices[0]["label"])

func _on_TextButton_pressed():
	update_menu(choices[0]["label"])

func _on_Back_Button_button_down():
	emit_signal("goto_adventure")

func _audio_done():
	_is_audio_done = true

func _on_visibility_changed():
	if visible:
		start()