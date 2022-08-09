extends Node2D

signal scored(amount)

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

var _num_obstacles = []
var _dodging_points = 100
var _points_to_give = 0
var _active_obstacles = 0
var _last_pattern = 0
var _was_hit = false

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

func _on_ObstacleTrash_area_entered(area):
	if area.is_in_group("Trashable"):
		_active_obstacles-=1
		area.queue_free()
		_num_obstacles[0]-=1
		_points_to_give += _dodging_points
		if _num_obstacles[0]==0: 
			_num_obstacles.pop_front()
			if not _was_hit:
				emit_signal("scored", _points_to_give)
			_was_hit = false
			_points_to_give = 0

func _on_Runner_chose_answer(answer):
	label.hide()
	for lane in lanes:
		lane.hide_text()

func spawn_obstacles():
	var choices = range(patterns.size())
	var i = 0
	while i < choices.size():
		var valid_next = false
		for j in range(patterns[_last_pattern].size()):
			if (not patterns[i][j]) and (not patterns[_last_pattern][j]):
				i+=1
				valid_next = true
				break
		if valid_next: continue
		choices.pop_at(i)
	var choice = choices[randi()%choices.size()]
	_last_pattern = choice
	if choice == 0: return
	_num_obstacles.push_back(0)
	var pattern = patterns[choice]
	var k = 0
	for lane in lanes:
		if pattern[k]:
			_num_obstacles[_num_obstacles.size()-1]+=1
			_active_obstacles+=1
			lane.spawn(10)
		k+=1

func start_obstacles():
	obstacle_timer.start()

func stop_obstacles():
	obstacle_timer.stop()

func _on_Player_player_hit():
	_was_hit = true
