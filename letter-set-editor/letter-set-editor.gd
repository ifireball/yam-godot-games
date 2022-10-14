extends WindowDialog


var letter_set_list: ItemList


func _enter_tree():
	letter_set_list = \
		$HSplitContainer/HBoxContainer/VSplitContainer/ItemList 


# Called when the node enters the scene tree for the first time.
func _ready():
	popup()
	letter_set_list.add_item("123")
	letter_set_list.add_item("ABC")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
