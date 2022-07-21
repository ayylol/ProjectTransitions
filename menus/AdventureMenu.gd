extends Control

signal goto_mainmenu
signal goto_module

func _on_back_button_down():
	emit_signal("goto_mainmenu")

func _on_Module_button_down():
	emit_signal("goto_module")
