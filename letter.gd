tool
extends Label

enum Button {BLUE, YELLOW, RED, GREEN}

var button_colors := {
	Button.BLUE: Color.darkblue,
	Button.YELLOW: Color.darkgoldenrod,
	Button.RED: Color.darkred,
	Button.GREEN: Color.webgreen,
}

var idle_animations: PoolStringArray

export(int, "Blue", "Yellow", "Red", "Green") var button_color = Button.BLUE setget set_button_color


func set_button_color(new_color: int):
	button_color = new_color
	self.add_color_override("font_color", button_colors[button_color])


func _reset_idle_timer():
	if Engine.editor_hint:
		return
	$IdleTimer.start(rand_range(5.0, 15.0))


# Called when the node enters the scene tree for the first time.
func _ready():
	_reset_idle_timer()
	idle_animations = []
	for anim_name in $AnimationPlayer.get_animation_list():
		if anim_name.begins_with("idle"):
			idle_animations.append(anim_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
	if $IdleAnimationPlayer.is_playing():
		return
	$IdleAnimationPlayer.play("idle_spin_z")
