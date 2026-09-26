extends Control
@onready var attack_button = $Actions/Attack
@onready var enemy_hp = $"Enemy HP"
@onready var question = $Question
@onready var actions = $Actions
@onready var question_bg = $"Question BG"
@onready var snekker_sprite = $"Enemy Sprite"

func _ready() -> void:
	Global.Snekker_HP = 100

func _process(delta: float) -> void:
	enemy_hp.value = Global.Snekker_HP
	if Global.Snekker_question == true:
		question.show()
		question_bg.show()
	else:
		question.hide()
		question_bg.hide()
	
	# Thresholds, not exact values: HP steps depend on how many questions the quiz has.
	if Global.Snekker_HP == 0:
		DialogueState.current_quest = "snake_quiz_complete"
		if Global.is_online:
			if Global.total_score < 0:
				Global.total_score = 0
			Statistics.postQuizScore(PlayerState.student_id, PlayerState.classroom_id, 5, Global.total_score)
		var root = get_node("/root")
		if root:
			root.get_tree().change_scene_to_file("res://scenes/levels/Floor1.tscn")
	elif Global.Snekker_HP <= 20:
		snekker_sprite.play("damaged_life_3")
	elif Global.Snekker_HP <= 50:
		snekker_sprite.play("damaged_life_2")
		enemy_hp.add_theme_color_override("font_color", "#933f45")
	elif Global.Snekker_HP <= 80:
		snekker_sprite.play("damaged_life_1")

func _on_attack_pressed() -> void:
	Global.Snekker_question = true
