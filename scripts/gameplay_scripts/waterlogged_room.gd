extends Control

# NOTE: 3 fraction problems per waterlogged room

@onready var water_level_bar = $water_level/TextureProgressBar
@onready var congrats = $Congrats

var already_added = false

var current_water_level = 100

const BUCKET_BADGES := {
	"water_room_1": "res://assets/main_character/onscreen_badges/Water Bucket 1 Badge.png",
	"water_room_2": "res://assets/main_character/onscreen_badges/Water Bucket 2 Badge.png",
	"water_room_3": "res://assets/main_character/onscreen_badges/Water Bucket 3 Badge.png",
}

func _ready() -> void:
	# The room's numbered bucket stands in for a speaker, as in the portal's preview.
	var badge = BUCKET_BADGES.get(DialogueState.current_quest)
	if badge:
		$FractionProblem.frame.portrait_texture = load(badge)
	else:
		$FractionProblem.frame.show_portrait = false

func _process(delta: float) -> void:
	water_level_bar.value = current_water_level
	#LEVEL COMPLETE!!!
	if current_water_level == 0 and not already_added:
		already_added = true
		if DialogueState.current_quest == "water_room_1":
			DialogueState.current_quest = "after_wr_1"
			PlayerState.autosave()
		elif DialogueState.current_quest == "water_room_2":
			DialogueState.current_quest = "after_wr_2"
			PlayerState.autosave()
		elif DialogueState.current_quest == "water_room_3":
			DialogueState.current_quest = "after_wr_3" 
			PlayerState.autosave()
		congrats.visible = true
		Global.add_energy()
		

func _on_fraction_problem_correct() -> void:
	var new_level = current_water_level - 35
	var tween = get_tree().create_tween()
	if new_level < 0 :
		new_level = 0
	tween.tween_property(self, "current_water_level", new_level, .5)
