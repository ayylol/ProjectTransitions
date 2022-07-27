extends Node2D

signal done_showing_text

const obstacle = preload("res://quiz_game/Obstacle.tscn")

export var move_time = 0.5

var to_hide = false

onready var spawn_point = $SpawnPoint
onready var text = $Text
onready var label = $Text/Label
onready var text_tween = $TextAnim
onready var text_rest_pos = $TextRestPos
onready var text_end_pos = $TextEndPos

func spawn(speed : int):
	var instance = obstacle.instance()
	add_child(instance)
	instance.position = spawn_point.position
	instance.speed = speed
	instance.calc_direction()

func show_text(msg: String):
	text.show()
	text.position = spawn_point.position
	label.bbcode_text = "[color=#474920]" + msg + "[/color]"
	text_tween.interpolate_property(
		text, "position",
		text.position, text_rest_pos.position, move_time, 
		Tween.TRANS_SINE,Tween.EASE_IN)
	text_tween.start()

func hide_text():
	to_hide = true
	text_tween.interpolate_property(
		text, "position",
		text.position, text_end_pos.position, move_time, 
		Tween.TRANS_SINE,Tween.EASE_IN)
	text_tween.start()

func _on_TextAnim_tween_all_completed():
	if to_hide:
		text.hide()
		emit_signal("done_showing_text")
		to_hide = false
