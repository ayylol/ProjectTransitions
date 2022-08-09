extends Control

func set_label(text):
	$Label.text = text

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
