extends Control

@onready var congrats_screen = $Congrats
@onready var fraction_problem = $FractionProblem
@onready var quick_tutorial = $Tutorials/QuickTutorial

var animation_player: AnimatedSprite2D

@onready var current_quest: String = DialogueState.current_quest

func _ready() -> void:
	match current_quest:
		"saisai_wheelbarrow":
			animation_player = $Saisai
			fraction_problem.quest_number = 1
		"dead_robots":
			animation_player = $Robot
			fraction_problem.quest_number = 2
	animation_player.visible = true

func _on_fraction_problem_all_done() -> void:
	if current_quest == "saisai_wheelbarrow":
		print("All done with simple, current quest is: ", current_quest)
		DialogueState.current_quest = "saisai_wheelbarrow_gameplay_done"
		PlayerState.autosave()
	elif current_quest == "dead_robots":
		DialogueState.current_quest = "dead_robots_gameplay_done"
		PlayerState.autosave()
	$Congrats.visible = true
	Global.add_energy()

func _on_fraction_problem_correct() -> void:
	$CorrectAnswerSFX.play()
	animation_player.play("correct")
	await animation_player.animation_finished
	animation_player.play("idle")

func _on_fraction_problem_incorrect() -> void:
	$WrongAnswerSFX.play()
	animation_player.play("wrong")
	await animation_player.animation_finished
	animation_player.play("idle")
