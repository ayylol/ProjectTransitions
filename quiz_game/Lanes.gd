extends Node2D

# WOULD BE MORE ROBUST IF THIS WAS DONE THROUGH CODE
var patterns = [
	[false,false,false],
	[true,false,false],
	[false,true,false],
	[false,false,true],
	[true,false,true],
	[true,true,false],
	[false,true,true],
]

var _last_pattern = 0

onready var label = $Label
onready var obstacle_timer = $ObstacleTimer
onready var lanes = get_tree().get_nodes_in_group("Lane")

func _on_Runner_show_question(question, answers):
	label.show()
	label.bbcode_text = question
	var i = 0
	for lane in lanes:
		lane.show_text(answers[i])
		i+=1


func _on_Runner_chose_answer(answer):
	label.hide()
	for lane in lanes:
		lane.hide_text()

func spawn_obstacles():
#	var choices = range(patterns.size())
#	var i = 0
#	print(choices)
#	while i < choices.size():
#		var valid_next = false
#		for j in range(patterns[_last_pattern].size()):
#			if (not patterns[i][j]) and (not patterns[_last_pattern][j]):
#				i+=1
#				valid_next = true
#				break
#		if valid_next: continue
#		choices.pop_at(i)
#	var choice = choices[randi()%choices.size()]
#	_last_pattern = choice
	var pattern = patterns[randi()%patterns.size()]
	var i = 0
	for lane in lanes:
		if pattern[i]:
			lane.spawn()
		i+=1
