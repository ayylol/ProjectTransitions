extends Control

# Mediator signals
signal goto_adventure
signal goto_quiz
signal goto_options

func _on_Adventure_Button_button_down():
	emit_signal("goto_adventure")


func _on_Directory_Button_button_down():
	emit_signal("goto_quiz")


func _on_Options_Button_button_down():
	emit_signal("goto_options")
