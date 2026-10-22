extends Control

@onready var objective = $"../ObjectiveOverlay"
@onready var badges = $"../OnscreenBadges"

# PauseScreen runs while the tree is paused (process_mode = always), so Esc can also resume.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_released("pause"):
		return
	if visible:
		_on_back_pressed()
	elif !DialogueState.in_dialogue:
		_pause()
	get_viewport().set_input_as_handled()

func _pause():
	show()
	get_tree().paused = true
	objective.visible = false
	badges.visible = false
	$Center/Card/VBox/Back.grab_focus()

func _on_back_pressed() -> void:
	hide()
	get_tree().paused = false
	PlayerState.player_in_dialogue = false
	objective.visible = true
	badges.visible = true

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	var saved_position = $"../..".get_player_position()
	PlayerState.saved_position = saved_position
	#part where you write the player stuff onto the database
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
