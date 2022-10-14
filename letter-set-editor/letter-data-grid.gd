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
	print(theme)

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
	var new_item: LetterDataItem = LetterDataItemScn.instance()
	grid.add_child(new_item)
	grid.move_child(new_item, add_button.get_index())
	new_item.connect("selected", self, "_on_LetterDataItem_selected")
	yield(get_tree(), "idle_frame")
	_fit_grid_columns()
	yield(get_tree(), "idle_frame")
	new_item.grab_focus()


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
