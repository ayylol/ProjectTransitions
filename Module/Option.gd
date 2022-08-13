extends ColorRect

onready var label = $MarginContainer/InnerBox/MarginContainer/RichTextLabel
onready var inner_box = $MarginContainer/InnerBox

var text = ""
var text_color = "fafac8"

func set_font(font):
	label.add_font_override("normal_font", font)

func set_text(new_text):
	text = new_text
	change_text()

func selected(is_selected):
	if is_selected:
		inner_box.color = Color(0.980392, 0.980392, 0.784314)
		text_color = "322b19"
	else:
		inner_box.color = Color(0.196078, 0.168627, 0.098039)
		text_color = "fafac8"
	change_text()

func change_text():
	label.bbcode_text = "[color=#"+text_color+"]" + text + "[/color]"
