extends Control

func _ready() -> void:
	$Buttons/Login.grab_focus()


func _on_register_button_down():
	get_tree().change_scene_to_file("res://scenes/student_scene/student_register.tscn")


func _on_login_button_down():
	get_tree().change_scene_to_file("res://scenes/student_scene/student_login.tscn")


func _on_offline_mode_button_down():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
