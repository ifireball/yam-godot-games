tool
extends ScrollContainer


const LetterDataItemScn := preload("res://letter-set-editor/letter-data-item.tscn")
const LetterDataItem := preload("res://letter-set-editor/letter-data-item.gd")

var grid: GridContainer
var add_button: Button
var bg_stylebox: StyleBox


func _enter_tree():
	grid = $GridContainer as GridContainer
	add_button = $GridContainer/AddButton as Button
	bg_stylebox = get_stylebox("bg", "Tree")
	add_stylebox_override("bg", bg_stylebox)
	
	
func _ready():
	if Engine.editor_hint:
		return
	_clear()
	var index := 0
	for letter in LetterData.load_all():
		add_item(index, letter)
		index += 1
	
	
func _clear():
	for item in grid.get_children():
		if item is LetterDataItem:
			del_item(item)
	

func _notification(what):
	match what:
		NOTIFICATION_RESIZED:
			_fit_grid_columns()
			
			
func _fit_grid_columns():
	print("- Adusting grid size: (%s, %s) %s" % [rect_size.x, grid.rect_size.x, grid.columns])
	while grid.rect_size.x < rect_size.x and grid.columns < grid.get_child_count():
		grid.columns += 1
		yield(get_tree(), "idle_frame")
	while grid.rect_size.x > rect_size.x and grid.columns > 1:
		grid.columns -= 1
		yield(get_tree(), "idle_frame")
	print("- Done Adusting grid size: (%s, %s) %s" % [rect_size.x, grid.rect_size.x, grid.columns])


func _on_AddButton_pressed():
	add_item(add_button.get_index())


func add_item(index: int, letter_data: LetterData = null):
	var new_item: LetterDataItem = LetterDataItemScn.instance()
	if letter_data:
		new_item.letter_data = letter_data
	else:
		# warning-ignore:return_value_discarded
		new_item.letter_data.save()
	grid.add_child(new_item)
	grid.move_child(new_item, index)
	# warning-ignore:return_value_discarded
	new_item.connect("selected", self, "_on_LetterDataItem_selected")
	# warning-ignore:return_value_discarded
	new_item.letter_data.connect("deleted", self, "del_item", [new_item])
	yield(get_tree(), "idle_frame")
	_fit_grid_columns()
	yield(get_tree(), "idle_frame")
	new_item.grab_focus()


func del_item(item: LetterDataItem):
	print("Deleting item %s" % item)
	item.letter_data.disconnect("deleted", self, "del_item")
	item.disconnect("selected", self, "_on_LetterDataItem_selected")
	grid.remove_child(item)
	if is_instance_valid(item):
		item.queue_free()


func _on_LetterDataItem_selected(item):
	print("selected: ", item)
	for other_item in grid.get_children():
		if other_item == item:
			continue
		if not other_item is LetterDataItem:
			continue
		(other_item as LetterDataItem).unselect()
	yield(get_tree(), "idle_frame")
	self.ensure_control_visible(item)


func _on_AddButton_focus_entered():
	_on_LetterDataItem_selected(add_button)
