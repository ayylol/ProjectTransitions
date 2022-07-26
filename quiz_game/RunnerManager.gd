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
onready var player = $Player

# TO TEST SPAWNING
func _unhandled_input(event):
	if event.is_action_pressed("test1"):
		lanes[0].spawn()
	elif event.is_action_pressed("test2"):
		lanes[1].spawn()
	elif event.is_action_pressed("test3"):
		lanes[2].spawn()
	elif event.is_action_pressed("ui_accept"):
		show_question()
	elif event.is_action_pressed("ui_right"): # THIS NEED TO BE MOVED
		emit_signal("chose_answer", player_lane)
		if player_lane == questions["choose the right answer"]["answer"]:
			print("correct")
		else:
			print("incorrect")

func _ready():
	player_lane = int(lanes.size()/2)
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])
	questions = Database.get_content("res://content/test_quiz.json")
	prompts = questions.keys()

func show_question():
	prompt = prompts[current_question]
	emit_signal("show_question", prompt, questions[prompt]["choices"])
	current_question +=1

func answer_question():
	emit_signal(prompt, player_lane)
	if player_lane == questions[prompt]["answer"]:
		print("correct")
	else:
		print("incorrect")

func _on_Player_moving(direction):
	var next_lane = player_lane + direction
	if next_lane >=0 and next_lane <lanes.size():
		player_lane = next_lane
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])

func _on_ObstacleTrash_area_entered(area):
	if area.is_in_group("Trashable"):
		area.queue_free()
