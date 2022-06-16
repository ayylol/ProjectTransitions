extends Control

export var topic := "intro"
signal goto_adventure

func _ready():
	update_menu("intro")

func update_menu(label):
	var data = Database.get(label)
	$VBoxContainer/HBoxContainer/RichTextLabel.text = data["text"]
	for i in range(data["choices"].size()):
		get_node("VBoxContainer/GridContainer/Button" + String(i)).text = data["choices"][i]

func _on_Button_button_down(extra_arg_0):
	update_menu(get_node("VBoxContainer/GridContainer/" + extra_arg_0).text)

func _on_Back_Button_button_down():
	emit_signal("goto_adventure")
