extends ColorRect

const options_to_font_size = {
	1 : 40,
	3 : 32,
	5 : 24,
	7 : 16
	
}
const option = preload("res://Module/Option.tscn")

signal done_showing_options

var selected = 0
var options

onready var options_container = $MarginContainer/InnerBox/MarginContainer/OptionsContainer

func initialize_options(choices, default_select):
	delete_children(options_container)
	var font_size
	for num_options in options_to_font_size.keys():
		font_size = options_to_font_size[num_options]
		if num_options >= choices.size():
			break
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://resources/fonts/texgyreadventor-regular.otf")
	dynamic_font.size = font_size
	for choice in choices:
		var new_option = option.instance()
		options_container.add_child(new_option)
		new_option.set_font(dynamic_font)
		new_option.set_text(choice)
		new_option.selected(false)
	options = options_container.get_children()
	selected = default_select
	options[selected].selected(true)

func select(num):
	assert(num<options.size() and num>=0, "trying to select a non-existent option")
	options[selected].selected(false)
	options[num].selected(true)
	selected = num

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
