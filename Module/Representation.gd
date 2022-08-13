extends VBoxContainer

onready var character_face = $MainCharacter

func update_portrait(path_to_portrait : String) -> bool:
	var directory = Directory.new()
	if directory.file_exists(path_to_portrait):
		var sprite = load(path_to_portrait)
		character_face.texture = sprite
		return true
	else:
		print(path_to_portrait + " does not exist")
		return false
