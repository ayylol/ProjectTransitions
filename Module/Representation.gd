extends VBoxContainer

onready var character_face = $MainCharacter
onready var person = $Padding/Person
onready var cat = $Padding/Cat

func update_portrait(path_to_portrait : String) -> bool:
	var directory = Directory.new()
	if directory.file_exists(path_to_portrait + ".import"):
		var sprite = load(path_to_portrait)
		character_face.texture = sprite
		return true
	else:
		print(path_to_portrait + " does not exist")
		return false

func change_character_anim(state: String): # Weird using string here
	match state:
		"walking":
			person.animation = "walking"
			cat.animation = "walking"
		"ask":
			person.animation = "ask"
			cat.animation = "idle"
		"idle":
			person.animation = "idle"
			cat.animation = "idle"
		_:
			person.animation = "idle"
			cat.animation = "idle"
