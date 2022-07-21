extends Node2D

signal show_question(question, answers)
signal chose_answer(answer)

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
		emit_signal("show_question", "what is 2+2", questions["what is 2+2"]["choices"])
	elif event.is_action_pressed("ui_right"): # THIS NEED TO BE MOVED
		emit_signal("chose_answer", player_lane)
		if player_lane == questions["what is 2+2"]["answer"]:
			print("correct")
		else:
			print("incorrect")

func _ready():
	player_lane = int(lanes.size()/2)
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])
	questions = Database.get_content("res://content/test_quiz.json")

func _on_Player_moving(direction):
	var next_lane = player_lane + direction
	if next_lane >=0 and next_lane <lanes.size():
		player_lane = next_lane
	player.move_to(lanes[player_lane].position, [0.75,1,1.25][player_lane])


func _on_ObstacleTrash_area_entered(area):
	if area.is_in_group("Trashable"):
		area.queue_free()
