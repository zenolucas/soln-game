extends Control
@onready var attack_button = $Attack/Attack
@onready var enemy_hp = $"Enemy HP"
@onready var question = $Question
@onready var question_bg = $"Question BG"

func _ready() -> void:
	Global.guardian_enemy_hp = 100

func _process(delta: float) -> void:
	enemy_hp.value = Global.guardian_enemy_hp
	
	if Global.guardian_enemy_question == true:
		question.show()
		question_bg.show()
		
	else:
		question.hide()
		question_bg.hide()

	if Global.guardian_enemy_hp <= 50:
		enemy_hp.add_theme_color_override("font_color", "#933f45")
	
	if Global.guardian_enemy_hp == 0:
		DialogueState.current_quest = "final_boss_quiz_successful"
		if Global.is_online:
			if Global.total_score < 0:
				Global.total_score = 0
			Statistics.postQuizScore(PlayerState.student_id, PlayerState.classroom_id, 12, Global.total_score)
		get_tree().change_scene_to_file("res://scenes/levels/Floor3.tscn")

func _on_attack_pressed() -> void:
	Global.guardian_enemy_question = true
