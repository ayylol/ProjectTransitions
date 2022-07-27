extends Node2D

signal show_question(question, answers)
signal chose_answer(answer)

var score = 0
var current_question = 0
var prompts
var prompt
var player_lane
var questions

onready var lanes = get_tree().get_nodes_in_group("Lane")
onready var lane_parent = $Lanes
onready var player = $Player
onready var question_timer = $QuestionTimer

func _ready():
	player_lane = int(lanes.size()/2)
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])
	questions = Database.get_content("res://content/test_quiz.json")
	prompts = questions.keys()

func show_question():
	if current_question < prompts.size():
		prompt = prompts[current_question]
		emit_signal("show_question", prompt, questions[prompt]["choices"])
		current_question +=1
	else:
		print("Game is done")

func answer_question():
	if prompt != null:
		emit_signal("chose_answer", player_lane)
		if player_lane == questions[prompt]["answer"]:
			print("correct")
		else:
			print("incorrect")

func _on_Player_moving(direction):
	var next_lane = player_lane + direction
	if next_lane >= 0 and next_lane < lanes.size():
		player_lane = next_lane
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])

func _on_Player_answer_question():
	answer_question()
	question_timer.start()
	lane_parent.start_obstacles()

func _on_QuestionTimer_timeout():
	lane_parent.stop_obstacles()
	show_question()
