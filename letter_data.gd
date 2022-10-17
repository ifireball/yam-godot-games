class_name LetterData
extends Resource

signal deleted

export(String) var glyph = "A" setget set_glyph


func _init():
	if not resource_name:
		var seq_num := 0
		var new_name: String
		while true:
			new_name = "letter%d" % seq_num
			if set_valid_name(new_name):
				break
			seq_num += 1


static func load_all() -> Array:
	var letters_dir: Directory = Directory.new()
	if (
		letters_dir.open("res://letters/") != OK 
		or letters_dir.list_dir_begin(true, true) != OK
	):
		print("Failed to read 'letters' resource directory")
		return []
	var letters := []
	var resouce_file_pattern = _make_resource_path("*")
	while true:
		var current_file = letters_dir.get_next()
		if not current_file:
			break
		if letters_dir.current_is_dir():
			continue
		current_file = letters_dir.get_current_dir().plus_file(current_file)
		print("May load resource: ", current_file)
		if not current_file.match(resouce_file_pattern):
			continue
		letters.append(ResourceLoader.load(current_file))
	letters.sort_custom(GlyphSorter, "sorter")
	return letters

class GlyphSorter:
	static func sorter(letter_a: LetterData, letter_b: LetterData) -> bool:
		return letter_a.glyph < letter_b.glyph


static func _make_resource_path(name: String) -> String:
	return "res://letters/%s.tres" % name


static func is_name_available(new_name: String) -> bool:
	if not new_name.is_valid_filename():
		return false
	var new_path := _make_resource_path(new_name)
	return not ResourceLoader.exists(new_path)


func set_valid_name(new_name: String) -> bool:
	print("set_valid_name(%s)" % new_name)
	if not new_name:
		print("Refusing to set resource name to an empty string")
		return false
	if not new_name.is_valid_filename():
		print("Refusing to set invalid name '%s' to '%s'" % [new_name, resource_name])
		return false
	if new_name == resource_name:
		return true
	if not is_name_available(new_name):
		print("Refusing to overwrite '%s' with '%s'" % [new_name, resource_name])
		return false
	resource_name = new_name
	emit_changed()
	return true


func set_glyph(new_glyph: String):
	print("set_glyph(%s)" % new_glyph)
	if len(new_glyph) == 1:
		glyph = new_glyph
		emit_changed()
	else:
		print("Refusing to set an invalid glyph value")


func save() -> int:
	var file_name := resource_name.strip_edges()
	if not file_name.is_valid_filename():
		print("Resource name is not a valid file name, refusing to save")
		return ERR_INVALID_DATA
	var old_resource_path = resource_path
	take_over_path(_make_resource_path(resource_name))
	var result = ResourceSaver.save(resource_path, self)
	if result == OK:
		print("Saved letter '%s' to '%s'" % [resource_name, resource_path])
	else:
		print("Saving letter data '%s' failed with %d" % [self.resource_name, result])
	if resource_path != old_resource_path:
		if old_resource_path && ResourceLoader.exists(old_resource_path):
			var some_dir = Directory.new()
			var remove_result = some_dir.remove(old_resource_path)
			if remove_result == OK:
				print("Deleted obsolete resource file:", old_resource_path)
			else:
				print("Failded of delete obsolete resource file '%s' with %d" %[
					old_resource_path, remove_result
				])
	return result


func delete() -> int:
	if not ResourceLoader.exists(resource_path):
		return OK
	var some_dir = Directory.new()
	var remove_result = some_dir.remove(resource_path)
	if remove_result == OK:
		print("Deleted resource file:", resource_path)
		emit_signal("deleted")
	else:
		print("Failded of delete resource file '%s' with %d" %[
			resource_path, remove_result
		])
	return remove_result
