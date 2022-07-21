extends Node2D

onready var label = $Label

func _on_Runner_show_question(question, answers):
	label.show()
	label.bbcode_text = question
	var i = 0
	for lane in get_children():
		if lane.is_in_group("Lane"):
			lane.show_text(answers[i])
			i+=1


func _on_Runner_chose_answer(answer):
	label.hide()
	for lane in get_children():
		if lane.is_in_group("Lane"):
			lane.hide_text()
