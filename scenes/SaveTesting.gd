extends Control

signal save

func _ready():
	if(OS.is_userfs_persistent()):
		$VBoxContainer/Label.text = "True"
	else:
		$VBoxContainer/Label.text = "False"

func save_state():
	var save_dict = {
		"text" : $VBoxContainer/TextEdit.text
	}
	return save_dict

func load_state(state_dict):
	$VBoxContainer/TextEdit.text = state_dict["text"]


func _on_Button_button_up():
	emit_signal("save")
