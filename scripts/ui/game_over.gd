extends Control

func _ready() -> void:
	$Character.play("game_over")
	$Retry.grab_focus()

func _on_character_animation_finished() -> void:
	$Character.play("default")

func _on_retry_pressed() -> void:
	Global.user_energy = 3
	match Global.current_floor:
		2:
			get_tree().change_scene_to_file("res://scenes/levels/Floor2.tscn")
		3:
			get_tree().change_scene_to_file("res://scenes/levels/Floor3.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/levels/Floor1.tscn")
