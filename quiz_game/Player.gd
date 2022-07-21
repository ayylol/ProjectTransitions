extends KinematicBody2D

signal moving(direction)

export var move_time = 0.1

var _can_move = true

onready var move_tween = $MoveTween

func _input(event):
	if _can_move:
		if event.is_action("ui_up"):
			emit_signal("moving", -1)
		elif event.is_action("ui_down"):
			emit_signal("moving", 1)

func move_to(new_pos : Vector2, new_scale: float):
	assert(_can_move, "Can't move right now")
	_can_move = false
	move_tween.interpolate_property(
		self, "position",
		position, new_pos, move_time, 
		Tween.TRANS_SINE,Tween.EASE_IN)
	move_tween.interpolate_property(
		self, "scale",
		scale, Vector2(new_scale,new_scale), move_time, 
		Tween.TRANS_SINE,Tween.EASE_IN)
	move_tween.start()


func _on_MoveTween_tween_all_completed():
	assert(not _can_move, "Shouldn't be able to move right now")
	_can_move = true
