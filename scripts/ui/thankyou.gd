extends Control

func _ready() -> void:
	$Center/Card/VBox/MainMenu.grab_focus()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
