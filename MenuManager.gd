extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Main Menu Goto's
func _on_Main_Menu_goto_adventure():
	$"Main Menu".hide()
	$"AdventureMenu".show()


func _on_AdventureMenu_goto_mainmenu():
	$"AdventureMenu".hide()
	$"Main Menu".show()
