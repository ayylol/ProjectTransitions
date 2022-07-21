extends Control


func _on_Quiz_visibility_changed():
	if visible:
		get_tree().change_scene("res://quiz_game/runner.tscn")
