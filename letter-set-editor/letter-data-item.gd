tool
extends PanelContainer


signal selected(item)


var bg_stylebox: StyleBox
var bg_selected_stylebox: StyleBox
var glyph_viewer: Label
var name_tabber: TabContainer
var name_editor: LineEdit
var name_viewer: Label
var focused_name_viewer: Label
var edit_buttons: Container
var glyph_edit_button: Button
var glyph_save_button: Button
var delete_button: Button
var glyph_cursor: Control
var glyph_cursor_anim: AnimationPlayer

enum NameEditMode {UNFOCUSED, VIEW, EDIT}

var glyph_edit_mode := false


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

	glyph_viewer = $VBox/Glyph	
	name_tabber = $VBox/NameTabber
	name_editor = $VBox/NameTabber/EditNameHBox/NameEditor
	name_viewer = $VBox/NameTabber/NameView
	focused_name_viewer = $VBox/NameTabber/FocusedNameHBox/FocusedNameView
	edit_buttons = $VBox/Glyph/EditButtonsVBox
	glyph_edit_button = $VBox/Glyph/EditButtonsVBox/GlyphEditButton
	glyph_save_button = $VBox/Glyph/EditButtonsVBox/GlyphSaveButton
	delete_button = $VBox/Glyph/EditButtonsVBox/DeleteButton
	glyph_cursor = $VBox/Glyph/GlyphCursor
	glyph_cursor_anim = $VBox/Glyph/GlyphCursor/GlyphAnimationPlayer


func _on_LetterDataItem_focus_entered():
	print("got focus: ", self)
	select()


func _on_LetterDataItem_focus_exited():
	_finish_glyph_edit()
	
	
func select():
	add_stylebox_override("panel", bg_selected_stylebox)
	name_tabber.current_tab = NameEditMode.VIEW
	edit_buttons.show()
	emit_signal("selected", self)
	
	
func unselect():
	add_stylebox_override("panel", bg_stylebox)
	name_tabber.current_tab = NameEditMode.UNFOCUSED
	_finish_glyph_edit()
	edit_buttons.hide()
	

func _on_LetterDataItem_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			return
		print("%s clicked" % self.name)
		grab_focus()
	elif event is InputEventKey:
		if event.pressed:
			return
		var scancode = event.get_scancode_with_modifiers()
		if glyph_edit_mode:
			if OS.is_scancode_unicode(scancode):
				var chr = char(event.unicode)
				if glyph_edit_mode and chr.strip_edges():
					print("Typed: '%s'" % chr)
					glyph_viewer.text = chr
			elif scancode == KEY_ESCAPE or scancode == KEY_ENTER:
				_finish_glyph_edit()
		else:
			print("scancode:", scancode)
			match scancode:
				KEY_E: _start_glyph_edit()
				KEY_R, KEY_F2: _start_name_edit()
	

func _on_NameEditButton_pressed():
	_start_name_edit()
	

func _start_name_edit():
	name_tabber.current_tab = NameEditMode.EDIT
	name_editor.grab_focus()


func _finish_name_edit():
	var new_name := name_editor.text
	if not new_name:
		new_name = name_viewer.text
		name_editor.text = new_name
	name_viewer.text = new_name
	focused_name_viewer.text = new_name
	name_tabber.current_tab = NameEditMode.VIEW
	call_deferred("grab_focus")


func _on_NameSaveButton_pressed():
	_finish_name_edit()


func _on_NameEditor_focus_exited():
	_finish_name_edit()


func _on_NameEditor_text_entered(_new_text):
	_finish_name_edit()


func _on_GlyphEditButton_pressed():
	_start_glyph_edit()
	
	
func _on_GlyphSaveButton_pressed():
	_finish_glyph_edit()


func _start_glyph_edit():
	if glyph_edit_mode:
		return
	glyph_edit_button.hide()
	delete_button.hide()
	glyph_save_button.show()
	glyph_cursor_anim.play("blink")
	glyph_edit_mode = true
	grab_focus()


func _finish_glyph_edit():
	if not glyph_edit_mode:
		return
	glyph_edit_mode = false
	glyph_cursor_anim.play("RESET")
	glyph_save_button.hide()
	delete_button.show()
	glyph_edit_button.show()
	call_deferred("grab_focus")
