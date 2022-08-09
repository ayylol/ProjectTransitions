extends Node2D

const score_popup = preload("res://quiz_game/ScorePopUp.tscn")

signal show_question(question, answers)
signal chose_answer(answer)

var score = 0
var current_question = 0
var prompts
var prompt
var player_lane
var questions
var game_going = true
var _question_ongoing = false
var _total_questions = 0
var _right_questions = 0

onready var lanes = get_tree().get_nodes_in_group("Lane")
onready var lane_parent = $Game/Lanes
onready var player = $Game/Player
onready var question_timer = $Game/QuestionTimer
onready var end_game_timer = $Game/EndGameTimer
onready var score_label = $Game/ScoreLabel

func _ready():
	player_lane = int(lanes.size()/2)
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])
	questions = Database.get_content("res://content/test_quiz.json")
	prompts = questions.keys()

func show_question():
	if current_question < prompts.size():
		prompt = prompts[current_question]
		emit_signal("show_question", prompt, questions[prompt]["choices"])
		_question_ongoing = true
		current_question +=1
	else:
		end_game_timer.start()
		print("Game is done")

func answer_question():
	if _question_ongoing:
		emit_signal("chose_answer", player_lane)
		if player_lane == questions[prompt]["answer"]:
			scored(1000)
			_right_questions +=1
		else:
			print("incorrect")
		_question_ongoing = false
		_total_questions +=1
		

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

func scored(amount : int):
	score += amount
	var instance = score_popup.instance()
	instance.set_label(String(amount))
	player.add_child(instance)
	score_label.text = String(score)


func _on_EndGameTimer_timeout():
	game_going = false
	$Game.hide()
	$Camera/EndScreen.show()
	$Camera/EndScreen/Score.text = "Score: " + String(score)
	$Camera/EndScreen/QuizResult.text = "Quiz Result: " + String(_right_questions) + "/" + String(_total_questions)


func _on_Button_button_down():
	get_tree().change_scene("res://systems/Root.tscn")
