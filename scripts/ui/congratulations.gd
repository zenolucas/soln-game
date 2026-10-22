extends Control

@export var next_scene: PackedScene
@onready var label: Label = $Center/Card/VBox/Label
@onready var ok_button: Button = $Center/Card/VBox/correct

func _ready() -> void:
	# Hosts nest this under scaled or tiny parents; always cover the whole screen.
	top_level = true
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = get_viewport_rect().size
	visibility_changed.connect(_on_visibility_changed)
	if DialogueState.current_quest == "saisai_wheelbarrow":
		label.text = "You have solved Saisai's problems!"
	elif DialogueState.current_quest == "dead_robots":
		label.text = "You have passed Old Peculiar's trial!"
	elif DialogueState.current_quest == "meeting_chip":
		label.text = "You have opened the safe!"
	elif DialogueState.current_quest == "water_room_1":
		label.text = "You have earned a bucket badge!"
	elif DialogueState.current_quest == "water_room_2":
		label.text = "You have earned a second bucket badge!"
	elif DialogueState.current_quest == "water_room_3":
		label.text = "You have earned a third bucket badge!"

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		ok_button.grab_focus.call_deferred()

func _on_correct_pressed():
	get_tree().change_scene_to_packed(next_scene)
