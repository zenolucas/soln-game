extends Control

@onready var inner_dial = $safe_dial/inner
@onready var congrats = $Congrats
@onready var fade = $fade
@onready var timer = $Timer

var safe_opened = false

func _on_fraction_problem_correct() -> void:
	var new_rotation = randf_range(10.0, 90.0)
	var direction = randi_range(1, 2)
	var tween = get_tree().create_tween()
	
	match direction:
		1:
			new_rotation * 1
		2:
			new_rotation * -1
	
	print(new_rotation)
	tween.tween_property(inner_dial, "rotation", new_rotation, .75)
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
