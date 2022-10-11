extends Node

const Letter = preload("res://letter.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_reset_level()

func _reset_level():
	_select_right_answer()
	_display_letters()

func _select_right_answer():
	var letters := get_tree().get_nodes_in_group("letters")
	var right_ans_idx := randi() % len(letters)
	var right_answer: Letter = letters[right_ans_idx]
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
	print("TODO: Animate letters entering here")
	get_tree().call_group("letters", "listen_for_answers")
	

func _on_right_answer_selected(letter: Letter):
	get_tree().call_group("wrong_answers", "fade_out")
	yield(letter, "right_answer_exit")
	print("TODO: Animate right answer exiting here")
	_reset_level()
