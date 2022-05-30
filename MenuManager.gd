extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Main Menu Goto's
func _on_Main_Menu_goto_adventure():
	$"Main Menu".hide()
	$"AdventureMenu".show()


func _on_AdventureMenu_goto_mainmenu():
	$"AdventureMenu".hide()
	$"Main Menu".show()


func _on_AdventureMenu_goto_testmodule():
	$"AdventureMenu".hide()
	$"Test Module".show()


func _on_Test_Module_goto_adventure():
	$"Test Module".hide()
	$"AdventureMenu".show()
