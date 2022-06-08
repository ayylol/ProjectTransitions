extends Control

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


func _on_Main_Menu_goto_options():
	$"Main Menu".hide()
	$"SaveTesting".show()


func _on_SaveTesting_save():
	$GameState.save_game()
