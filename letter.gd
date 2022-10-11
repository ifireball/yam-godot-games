tool
extends Control

enum Button {BLUE, YELLOW, RED, GREEN}

const button_colors := {
	Button.BLUE: Color.darkblue,
	Button.YELLOW: Color.darkgoldenrod,
	Button.RED: Color.darkred,
	Button.GREEN: Color.webgreen,
}

const LETTERS := [
	"א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט", "י", "כ", 
	"ל", "מ", "נ", "ס", "ע", "מ", "צ", "ק", "ר", "ש", "ת"
]


export(int, "Blue", "Yellow", "Red", "Green") var button_color = Button.BLUE setget set_button_color
export(String) var letter := "א" setget set_letter
export(bool) var is_right_answer := false


signal right_answer_selected(letter)
signal right_answer_exit(letter)


var idle_animations: PoolStringArray


func set_button_color(new_color: int):
	button_color = new_color
	$Glyph.add_color_override("font_color", button_colors[button_color])


func set_letter(new_letter: String):
	if new_letter:
		letter = new_letter[0]
	else:
		letter = LETTERS[0]
	$Glyph.text = letter


func _reset_idle_timer():
	if Engine.editor_hint:
		return
	$IdleTimer.start(rand_range(5.0, 15.0))


func _ready():
	idle_animations = []
	for anim_name in $AnimationPlayer.get_animation_list():
		if anim_name.begins_with("idle"):
			idle_animations.append(anim_name)


func _on_IdleTimer_timeout():
	var anim_name = idle_animations[randi() % len(idle_animations)]
	print("%s is idle. Playing: %s" % [self.name, anim_name])
	$AnimationPlayer.play(anim_name)
	yield($AnimationPlayer, "animation_finished")
	_reset_idle_timer()


func _on_Letter_gui_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.pressed:
		return
	print("%s clicked" % self.name)
	_on_selected()


static func _wait_anim_queue_end(player: AnimationPlayer):
	while true:
		yield(player, "animation_finished")
		if not player.get_queue():
			break


func _on_selected():
	print("%s selected" % self.name)
	$IdleTimer.stop()
	$AnimationPlayer.clear_queue()
	if is_right_answer:
		emit_signal("right_answer_selected", self)
		$AnimationPlayer.queue("idle_spin_z")
		yield(_wait_anim_queue_end($AnimationPlayer), "completed")
		emit_signal("right_answer_exit", self)
	else:
		$AnimationPlayer.queue("refuse")
		yield(_wait_anim_queue_end($AnimationPlayer), "completed")
		_reset_idle_timer()


func fade_out():
	$IdleTimer.stop()
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.queue("fadeout")


func reset():
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("RESET")
	
	
func listen_for_answers():
	if is_right_answer:
		print("TODO: Play the question audio here")
	_reset_idle_timer()
