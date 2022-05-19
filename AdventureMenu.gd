extends Control

signal goto_mainmenu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_back_button_down():
	emit_signal("goto_mainmenu")
