extends Control

var topic := "intro"
var choices = []
signal goto_adventure

func _ready():
	#GameState.load_game()
	Database.load_flags("flags")
	Database.load_module("module1")
	#Database.load_flags("test_flags")
	#Database.load_module("test")
	update_menu(topic)

func update_menu(label):
	topic = label
	var data = Database.get(label)
	$VBoxContainer/HBoxContainer/RichTextLabel.text = data["text"]
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
		"edited_flags" : Database.edited_flags
	}
	return save_dict

func load_state(state_dict):
	topic = state_dict["topic"]
	Database.edited_flags = state_dict["edited_flags"]
