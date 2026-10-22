extends Control

@onready var inner_dial = $Art/safe_dial/inner
@onready var congrats = $Congrats
@onready var fade = $fade
@onready var timer = $Timer

var safe_opened = false

func _on_fraction_problem_correct() -> void:
	var turn = randf_range(90.0, 270.0)
	if randi_range(1, 2) == 2:
		turn *= -1
	var tween = get_tree().create_tween()
	tween.tween_property(inner_dial, "rotation_degrees", inner_dial.rotation_degrees + turn, .75)
	await tween.finished
	if safe_opened:
		fade.play("fade")
		timer.start()

func _on_fraction_problem_all_done() -> void:
	DialogueState.current_quest = "chip_gameplay_done"
	PlayerState.autosave()
	safe_opened = true
	Global.add_energy()

func _on_timer_timeout() -> void:
	congrats.visible = true
