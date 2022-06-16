extends Control

signal goto_mainmenu
signal goto_testmodule

func _on_back_button_down():
	emit_signal("goto_mainmenu")


func _on_TestModule_button_down():
	emit_signal("goto_testmodule")
