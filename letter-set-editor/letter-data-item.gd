tool
extends PanelContainer


signal selected(item)


var bg_stylebox: StyleBox
var bg_selected_stylebox: StyleBox
var name_tabber: TabContainer
var name_editor: LineEdit
var name_viewer: Label
var focused_name_viewer: Label


enum NameEditMode {UNFOCUSED, VIEW, EDIT}


func _enter_tree():
	bg_stylebox = get_stylebox("bg", "Control").duplicate()
	bg_selected_stylebox = get_stylebox("selected_focus", "Tree")
	bg_stylebox.content_margin_top = bg_selected_stylebox.content_margin_top
	bg_stylebox.content_margin_left = bg_selected_stylebox.content_margin_left
	bg_stylebox.content_margin_bottom = bg_selected_stylebox.content_margin_bottom
	bg_stylebox.content_margin_right = bg_selected_stylebox.content_margin_right
	print(bg_stylebox, bg_stylebox.content_margin_top, bg_stylebox.content_margin_bottom)
	print(bg_selected_stylebox, bg_selected_stylebox.content_margin_top, bg_selected_stylebox.content_margin_bottom)
	add_stylebox_override("panel", bg_stylebox)
	
	name_tabber = $VBox/NameTabber
	name_editor = $VBox/NameTabber/EditNameHBox/NameEditor
	name_viewer = $VBox/NameTabber/NameView
	focused_name_viewer = $VBox/NameTabber/FocusedNameHBox/FocusedNameView


func _on_LetterDataItem_focus_entered():
	print("got focus: ", self)
	select()


func select():
	add_stylebox_override("panel", bg_selected_stylebox)
	name_tabber.current_tab = NameEditMode.VIEW
	emit_signal("selected", self)
	
	
func unselect():
	add_stylebox_override("panel", bg_stylebox)
	name_tabber.current_tab = NameEditMode.UNFOCUSED
		

func _on_LetterDataItem_gui_input(event):
	if not event is InputEventMouseButton:
		return
	if event.pressed:
		return
	print("%s clicked" % self.name)
	grab_focus()
	

func _on_NameEditButton_pressed():
	name_tabber.current_tab = NameEditMode.EDIT
	name_editor.grab_focus()


func _finish_name_edit():
	var new_name := name_editor.text
	if not new_name:
		return
	name_viewer.text = new_name
	focused_name_viewer.text = new_name
	name_tabber.current_tab = NameEditMode.VIEW


func _on_NameSaveButton_pressed():
	_finish_name_edit()


func _on_NameEditor_focus_exited():
	_finish_name_edit()


func _on_NameEditor_text_entered(_new_text):
	_finish_name_edit()
