extends Control

export var topic := "intro"
signal goto_adventure

func _ready():
	GameState.load_game()
	Database.load_flags()
	Database.load_module("module1")
	update_menu(topic)

func update_menu(label):
	topic = label
	var data = Database.get(label)
	$VBoxContainer/HBoxContainer/RichTextLabel.text = data["text"]
	var i = 0
	for b in $VBoxContainer/GridContainer.get_children():
		if i < data["choices"].size():
			b.text = data["choices"][i]
			b.show()
		else:
			b.hide()
		i+=1

func _on_Button_button_down(extra_arg_0):
	update_menu(get_node("VBoxContainer/GridContainer/" + extra_arg_0).text)
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
