extends Area2D

signal player_hit

export var speed = 10.0

var target = Vector2(0,0)

var _dir

func _ready():
	calc_direction()

func calc_direction():
	_dir = (target - position).normalized()

func _physics_process(delta):
	position = position + _dir * speed


func _on_Obstacle_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("player_hit")
		print("hit")
