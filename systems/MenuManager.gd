extends Control

func _ready():
	pass
	# TODO: think about where this 
	#GameState.load_game()

# Main Menu Goto's
func _on_Main_Menu_goto_adventure():
	$"Main Menu".hide()
	$"AdventureMenu".show()


func _on_AdventureMenu_goto_mainmenu():
	$"AdventureMenu".hide()
	$"Main Menu".show()


func _on_AdventureMenu_goto_testmodule():
	$"AdventureMenu".hide()
	$"Module".show()


func _on_Test_Module_goto_adventure():
	$"Module".hide()
	$"AdventureMenu".show()


