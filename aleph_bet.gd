extends Node2D

const Letter = preload("res://letter.gd")

onready var tween := $Tween as Tween
onready var viewport_rect := get_viewport_rect() as Rect2
onready var viewport_center := (viewport_rect.position + viewport_rect.size / 2)


func _ready():
	randomize()
	_reset_level()


func _reset_level():
	_select_right_answer()
	_display_letters()


func _select_right_answer():
	var letters := get_tree().get_nodes_in_group("letters")
	var right_ans_idx := randi() % len(letters)
	var right_answer: Letter = letters[right_ans_idx] as Letter
	print("Selected right answer: %s" % right_answer)
	letters.remove(right_ans_idx)
	right_answer.is_right_answer = true
	if right_answer.is_in_group("wrong_answers"):
		right_answer.remove_from_group("wrong_answers")
	for wrong_answer in letters:
		wrong_answer.is_right_answer = false
		wrong_answer.add_to_group("wrong_answers")
	

func _display_letters():
	get_tree().call_group("letters", "reset")
	var delay := 0.0
	var letters := get_tree().get_nodes_in_group("letters")
	letters.shuffle()
	for letter in letters:
		tween.interpolate_property(
			letter, @"rect_position", 
			viewport_center, 
			letter.rect_position, 
			3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay
		)
		tween.interpolate_property(
			letter, @"rect_scale", 
			Vector2.ZERO, 
			letter.rect_scale, 
			3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay
		)
		(letter as Letter).rect_position = viewport_center
		(letter as Letter).rect_scale = Vector2.ZERO
		delay = delay + 0.25
	tween.start()
	yield(tween, "tween_all_completed")
	print("letters have entered")
	get_tree().call_group("letters", "listen_for_answers")
	

func _on_right_answer_selected(letter: Letter):
	get_tree().call_group("wrong_answers", "fade_out")
	yield(letter, "right_answer_exit")
	var exit_scale := 3.0
	var letter_current_position := letter.rect_position
	var letter_current_scale := letter.rect_scale
	var letter_currnet_pivot := letter_current_position + letter.rect_pivot_offset * letter.rect_scale
	var letter_exit_size := letter.rect_size * letter.rect_scale * exit_scale
	var exit_destination := Vector2(
		viewport_rect.position.x - letter_exit_size.x
		if letter_currnet_pivot.x <= viewport_center.x
		else viewport_rect.position.x + viewport_rect.size.x
		,
		viewport_rect.position.y - letter_exit_size.y
		if letter_currnet_pivot.y <= viewport_center.y
		else viewport_rect.position.y + viewport_rect.size.y
	)
	tween.interpolate_property(
		letter, @"rect_position",
		letter_current_position,
		exit_destination, 
		1.0, Tween.TRANS_CUBIC, Tween.EASE_IN
	)
	tween.interpolate_property(
		letter, @"rect_scale",
		letter.rect_scale,
		letter.rect_scale * exit_scale, 
		1.0, Tween.TRANS_CUBIC, Tween.EASE_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	# Reset position because the Letter does not to reset its own position
	letter.rect_position = letter_current_position
	letter.rect_scale = letter_current_scale
	_reset_level()


func _unhandled_input(_event):
	if Input.is_action_just_released("exit"):
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	elif Input.is_action_just_released("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
