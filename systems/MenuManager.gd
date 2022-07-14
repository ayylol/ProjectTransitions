extends Camera2D

var _ui_node_path = "UI/"
var current_screen : Node

func _ready():
	current_screen = get_node(_ui_node_path + "MainMenu")
	current_screen.show()

func _show_menu(node_name: String):
	current_screen.hide()
	current_screen = get_node(_ui_node_path +  node_name)
	current_screen.show()
