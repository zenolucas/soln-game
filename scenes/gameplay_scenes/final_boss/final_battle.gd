extends Control
@onready var attack_button = $Attack/Attack
@onready var enemy_hp = $"Enemy HP"
@onready var question = $Question
@onready var question_bg = $"Question BG"
@onready var boss_light = $FinalBoss/PointLight2D

func _ready() -> void:
	attack_button.grab_focus()
	question.visibility_changed.connect(func():
		if not question.visible:
			attack_button.grab_focus.call_deferred())
	Global.guardian_enemy_hp = 100

func _process(delta: float) -> void:
	enemy_hp.value = Global.guardian_enemy_hp
	
	if Global.guardian_enemy_question == true:
		question.show()
		question_bg.show()
		boss_light.hide() # the boss's glow would otherwise tint the quiz panel
		
	else:
		question.hide()
		question_bg.hide()
		boss_light.show()

	
	if Global.guardian_enemy_hp == 0:
		DialogueState.current_quest = "final_boss_quiz_successful"
		PlayerState.autosave()
		if Global.is_online:
			if Global.total_score < 0:
				Global.total_score = 0
			Statistics.postQuizScore(PlayerState.student_id, PlayerState.classroom_id, 12, Global.total_score)
		get_tree().change_scene_to_file("res://scenes/levels/Floor3.tscn")

func _on_attack_pressed() -> void:
	Global.guardian_enemy_question = true
