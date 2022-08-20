extends Control

enum State {
	IDLE,
	SHOW_TEXT,
	SHOW_OPTIONS,
	HIDE_OPTIONS,
}
var state = State.IDLE

const quiz_choices_text = [
	"7 - Extremely true",
	"6 - Very true",
	"5 - Fairly true",
	"4 - Neither true nor false",
	"3 - Fairly false",
	"2 - Very false",
	"1 - Extremely false",
]

signal goto_adventure

var changed_character_anim = false

export var text_speed := 100.0
export var options_size := 1.0
export var options_delta_size := 10.0
export var showing_options_box := false

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
var _selected_option := 0
var _can_select_options := false
var _is_audio_done := true

onready var dialogue_box = $VBoxContainer/Ground/MarginContainer/RichTextLabel
onready var continue_indicator = $VBoxContainer/Ground/MarginContainer/RichTextLabel/ContinueIndicator
onready var options_box = $VBoxContainer/HBoxContainer/Padding/HBoxContainer/OptionsBox
onready var representation = $VBoxContainer/HBoxContainer/Representation
onready var audio = $AudioSource
onready var anim = $AnimationPlayer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_Back_Button_button_down()
	if state == State.IDLE:
		if event.is_action_pressed("ui_accept"):
				state = State.HIDE_OPTIONS
				set_process(true)
		if _can_select_options:
			if event.is_action_pressed("ui_up"):
				_selected_option=max(0, _selected_option-1)
				options_box.select(_selected_option)
			if event.is_action_pressed("ui_down"):
				var max_option = 6 if choices[0]["text"]=="{quiz}" else choices.size()-1
				_selected_option=min(max_option,_selected_option+1)
				options_box.select(_selected_option)

func _ready():
	set_process(false)

func start():
	#GameState.load_game()
	load_flags("flags")
	load_module("documentation")
	update_menu(topic)

func update_menu(label : String):
	if label == "{quiz}":
		get_tree().change_scene("res://quiz_game/runner.tscn")
		return
	var directory = Directory.new() # For file checking
	topic = label
	# Check for correct formating
	assert(label in _module_content, "label not in module")
	var content = _module_content[label]
	assert("choices" in content, "No choices in label")
	
	if "effect" in content:
		for key in content["effect"]:
			change_flag(key, content["effect"][key])
	
	# Get list of available choices
	choices.clear()
	var choices_text = []
	if content["choices"][0]["text"] == "{quiz}":
		#TODO: Fix quiz options
		choices_text = quiz_choices_text
		choices.append(content["choices"][0])
		_selected_option = 3
	else:
		for choice in content["choices"]:
			if "flag" in choice:
				if eval(choice["flag"]):
					choices.append(choice)
					choices_text.append(choice["text"])
			else:
				choices.append(choice)
				choices_text.append(choice["text"])
		_selected_option=0
	options_box.initialize_options(choices_text, _selected_option)
	
	
	# Get content to display
	var to_show = {"text": "", "audio": "", "character": "", "emotion": ""}
	get_label_vals(content, to_show)
	if "conditional" in content:
		for cond in content["conditional"].keys():
			if eval(cond):
				get_label_vals(content["conditional"][cond], to_show)
				break
	
	# Update text
	dialogue_box.bbcode_text = "[color=#fafac8]" + to_show["text"] + "[/color]"
	#dialogue_box.bbcode_text = to_show["text"]
	
	# Update audio
	if to_show["audio"]!="":
		var path_to_audio = "res://resources/audio/"+ _module_name + "/" + to_show["audio"] + ".ogg"
		if directory.file_exists(path_to_audio + ".import"):
			_is_audio_done=false
			audio.stream = load(path_to_audio)
			audio.play()
		else:
			print(path_to_audio + " does not exist")
	
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
		if representation.update_portrait(path_to_portrait):
			character = next_character
			emotion = next_emotion
	
	_visible_char_float = 0.0
	dialogue_box.visible_characters = _visible_char_float
	state = State.SHOW_TEXT
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
	match state:
		State.IDLE:
			set_process(false)
		State.SHOW_TEXT:
			if not changed_character_anim:
				representation.change_character_anim("walking")
				changed_character_anim = true
			if dialogue_box.visible_characters < dialogue_box.text.length():
				_visible_char_float += text_speed * delta
				dialogue_box.visible_characters = round(_visible_char_float)
			elif _is_audio_done:
				state = State.SHOW_OPTIONS
				changed_character_anim = false
		State.SHOW_OPTIONS:
			if "text" in choices[0] and choices[0]["text"] == "{next}":
				continue_indicator.show()
				representation.change_character_anim("idle")
				state = State.IDLE
			else:
				representation.change_character_anim("ask")
				anim.play("slide")
				anim.connect("animation_finished", self, "done_showing_optionbox")
				set_process(false)
		State.HIDE_OPTIONS:
			if continue_indicator.visible:
				continue_indicator.hide()
				select()
			elif not anim.is_playing():
				anim.play_backwards("slide")
				anim.connect("animation_finished", self, "done_hiding_options")
				set_process(false)
		_:
			state = State.IDLE

func done_showing_optionbox(_arg):
	anim.disconnect("animation_finished", self, "done_hiding_options")
	state = State.IDLE
	_can_select_options = true

func done_hiding_options(_arg):
	anim.disconnect("animation_finished", self, "done_hiding_options")
	_can_select_options = false
	select()

func select():
	if choices[0]["text"] == "{quiz}":
		var val = _selected_option + 1
		var qst = choices[0]
		if not qst["reversed"]:
			val = 8 - val
		if not qst["group"] in _quiz_answers:
			_quiz_answers[qst["group"]] = {}
		_quiz_answers[qst["group"]][qst["name"]] = val
		update_menu(choices[0]["label"])
	else:
		update_menu(choices[_selected_option]["label"])

func _on_Back_Button_button_down():
	audio.stop()
	emit_signal("goto_adventure")

func _audio_done():
	_is_audio_done = true

func _on_visibility_changed():
	if visible:
		start()
