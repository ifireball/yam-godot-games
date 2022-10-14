tool
class_name LetterSet
extends Resource

# export(Array, Resource) var letter := []
export (String) var display_name = ""
var letters: Array = []

func _get_property_list():
	var properties = []
	properties.append({
		# "class_name": "LetterData", 
		"hint": 26,  # PROPERTY_HINT_TYPE_STRING
		"hint_string": "17/19:LetterData", 
		# "hint_string": "17/19:Resource", 
		"name": "letters", 
		"type": TYPE_ARRAY,
		# "usage": 8199,
	})
	return properties
