extends Control
@onready var attack_button = $Attack/Attack
@onready var enemy_hp = $"Enemy HP"
@onready var question = $Question
@onready var question_bg = $"Question BG"

func _ready() -> void:
	attack_button.grab_focus()
	question.visibility_changed.connect(func():
		if not question.visible:
			attack_button.grab_focus.call_deferred())
	Global.Giant_Enemy_Crab_HP = 100

func _process(delta: float) -> void:
	enemy_hp.value = Global.Giant_Enemy_Crab_HP
	if Global.Giant_Enemy_Crab_question == true:
		question.show()
		question_bg.show()
	else:
		question.hide()
		question_bg.hide()
	
	
	
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
