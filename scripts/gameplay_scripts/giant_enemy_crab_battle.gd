extends Control
@onready var attack_button = $Actions/Attack
@onready var enemy_hp = $"Enemy HP"
@onready var question = $Question
@onready var actions = $Actions
@onready var question_bg = $"Question BG"

func _ready() -> void:
	Global.Giant_Enemy_Crab_HP = 100

func _process(delta: float) -> void:
	enemy_hp.value = Global.Giant_Enemy_Crab_HP
	if Global.Giant_Enemy_Crab_question == true:
		question.show()
		question_bg.show()
	else:
		question.hide()
		question_bg.hide()
	
	if Global.Giant_Enemy_Crab_HP <= 50:
		enemy_hp.add_theme_color_override("font_color", "#933f45")
	
	
	if Global.Giant_Enemy_Crab_HP == 0:
		DialogueState.current_quest = "crab_quiz_successful"
		PlayerState.autosave()
		if Global.is_online:
			if Global.total_score < 0:
				Global.total_score = 0
			Statistics.postQuizScore(PlayerState.student_id, PlayerState.classroom_id, 11, Global.total_score)
		get_tree().change_scene_to_file("res://scenes/levels/Floor2.tscn")

func _on_attack_pressed() -> void:
	Global.Giant_Enemy_Crab_question = true
