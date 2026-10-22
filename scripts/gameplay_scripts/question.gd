extends Control
## The multiple-choice panel shared by the Snekkers, Crab and Final Boss quizzes.
## Laid out like the teacher portal's quiz preview: the speaker's portrait, a speech
## box with the question, then a 2x2 grid of lettered choices.

const LETTERS := "ABCD"
const FEEDBACK_SECONDS := 0.8
const LONG_TEXT := 90
const LONG_CHOICE := 16

## The enemy's picture, shown beside the question.
@export var portrait: Texture2D

@onready var content: Label = %Content
@onready var portrait_rect: TextureRect = %Portrait
@onready var feedback: Label = %Feedback
@onready var choice_buttons: Array[Button] = [%Choice1, %Choice2, %Choice3, %Choice4]
@onready var mc_questions
@onready var mc_choice_ids
@onready var camera = $"../Camera2D"
@onready var wrong_sfx: AudioStreamPlayer = $"../WrongSFX"
@onready var correct_sfx: AudioStreamPlayer = $"../CorrectSFX"

var index
var correct_answer
var answer
var rng = RandomNumberGenerator.new()
var question
# Number of questions this fight started with (set on the first answer, before any is removed).
var question_count := 0
# The current question's choices as written, without their "A. " labels.
var choices: Array[String] = []
var _locked := false

static func choice_label(choice_index: int, text: String) -> String:
	return "%s. %s" % [LETTERS[choice_index], text]

static func is_correct(chosen, correct) -> bool:
	return str(chosen) == str(correct)

func _ready():
	portrait_rect.texture = portrait
	portrait_rect.visible = portrait != null
	for i in choice_buttons.size():
		choice_buttons[i].pressed.connect(_on_choice_pressed.bind(i))
	visibility_changed.connect(_on_visibility_changed)
	if Global.is_online:
		print("ONLINE MODE: CURRENT QUEST IS: ", DialogueState.current_quest)
		QuestionsLoader.connect("questions_loaded", _on_questions_loaded)
		QuestionsLoader.questions_failed.connect(_on_questions_failed)
		if DialogueState.current_quest == "face_the_snake_post_cutscene":
			QuestionsLoader.get_snekkers_questions()
		elif DialogueState.current_quest == "crab_boss":
			print("crab questions")
			QuestionsLoader.get_crab_questions()
		else:
			# QuestionsLoader.get_final_boss_questions()
			# ugly fix to final boss online bug, questions are already loaded in floor3.tscn, just load them
			mc_questions = QuestionsLoader.final_boss_questions
			mc_choice_ids = QuestionsLoader.final_boss_choice_ids
			Global.total_score = mc_questions.size()
			
	else:
		# else get OFFLINE VALUES FOR QUIZ
		print("OFFLINE MODE: Current quest is: ", DialogueState.current_quest)
		
		# questions for snekkers
		if DialogueState.current_quest == "face_the_snake_post_cutscene":
			mc_questions = [
			["What is the numerator in the fraction 5/6?", "6", "5", "/", "30", "5"],
			["What is 1/3 + 1/3?", "1/2", "2/3", "3/3", "4/3", "2/3"],
			["What is 1/5 + 2/5?", "1/5", "3/5", "4/5", "1", "3/5"],
			["What is 2/6 + 1/6?", "3/6", "4/6", "1/6", "1/2", "1/2"],
			["What does GCD stand for?", "Great Common Denominator", "Greatest Common Denominator", "Greatest Common Difference", "Greatest Common Divisor", "Greatest Common Divisor"],
			["What is 1/2 + 2/4?", "3/4", "1", "1/2", "2/4", "1"],
			["What is 1/3 + 2/3?", "1/3", "1", "2", "3/3", "1"],
			["Which fraction is bigger: 3/4 or 2/3?", "They are equal", "2/3", "3/4", "Neither", "3/4"],
			["What is 3/10 + 4/10?", "1/10", "1/2", "7/10", "8/10", "7/10"],
			["What is 1/6 + 1/3?", "1/2", "2/6", "3/6", "4/6", "1/2"]
			]
		## questions for final boss
		elif DialogueState.current_quest == "final_boss_quest_retry" || DialogueState.current_quest == "crab_quiz_after":
			mc_questions = [
				["If you have a fraction 5/6, what is the numerator?", "6", "5", "10", "8", "5"],
				["You share one thirds of a pizza with a friend and then add another one thirds of another pizza. How much pizza do you have in total?", "1/2", "2/3", "3/3", "4/3", "2/3"],
				["Saisai ate one-fifth of a cake, and his friend ate two-fifths. Together, how much of the cake did they eat?", "1/5", "3/5", "4/5", "1", "3/5"],
				["Robob poured 2/6 of juice into a glass and later added 1/6 more. How much juice is in the glass now?", "3/6", "4/6", "1/6", "1/2", "1/2"],
				["In math, what does GCD stand for?", "Great Common Denominator", "Greatest Common Denominator", "Greatest Common Difference", "Greatest Common Divisor", "Greatest Common Divisor"],
				["Chip cut her apple in half (1/2) and then cut another apple in half (2/4). How much apple does she have in total?", "3/4", "1", "1/2", "2/4", "1"],
				["If you add 1/3 of a cup of flour to 2/3 of a cup of flour, how much do you have altogether?", "1/3", "1", "2", "3/3", "1"],
				["You have 3/4 of a chocolate bar and your friend has 2/3 of another chocolate bar. Which fraction represents the larger portion?", "They are equal", "2/3", "3/4", "Neither", "3/4"],
				["If 3/8 is equal to (blank)/24, what should the numerator be?", "6", "9", "12", "15", "9"],
				["If you drink 1/6 of a bottle of water and later drink another 1/3, how much water have you consumed?", "1/2", "2/6", "3/6", "4/6", "1/2"],
				["You had half (1/2) of a sandwich, but gave away one-quarter (1/4) to a friend. What fraction of the sandwich is left?", "1/2", "1/4", "1/8", "3/4", "1/4"],
				["You started with 5/6 of a pie and shared half of it (1/2) with a neighbor. How much pie do you have left?", "1/6", "1/3", "1/4", "1/2", "1/3"],
				["If you have a fraction ten over fifteen, what is the denominator?", "15", "5", "10", "8", "10"],
				["If you have two-thirds (2/3) of a cup of milk and remove one-sixth (1/6) of it, how much milk is left?", "1/6", "1/2", "1/3", "5/6", "1/2"],
				["In fractions, what does LCD stand for?", "Lowest Common Divisor", "Least Common Denominator", "Levelled Common Divisor", "Lower Common Divisor", "Least Common Denominator"],
				["You have two halves (2/2) of a pie and give one-half away. How much pie do you have left?", "1/2", "1/4", "3/4", "2/4", "1/2"],
				["If you start with 5/6 of a tank of gas and use one-third (1/3) of it, how much gas remains?", "1/2", "1/3", "2/3", "5/6", "1/2"],
				["A recipe requires three-quarters (3/4) of a cup of sugar, but you only use one-quarter (1/4) of a cup. How much sugar do you have left?", "2/4", "1/2", "3/4", "1", "1/2"],
				["You have 7/10 of a chocolate bar and eat 3/10. How much chocolate is left?", "1/5", "4/10", "7/10", "1/2", "4/10"],
				["What denominator would make 4/7 equivalent to 12/(blank)?", "14", "24", "18", "21", "21"],
			]

		# questions for crab
		else:
			print("Current quest is: ", DialogueState.current_quest)
			mc_questions = [
			["What is 1/2 - 1/4?", "1/2", "1/4", "1/8", "3/4", "1/4"],
			["You start with 5/6 of a pie and give away 1/2 of the pie to a neighbor. How much fraction of pie, you have left?", "1/6", "1/3", "1/4", "1/2", "1/3"],
			["What is 4/5 - 1/5?", "2/5", "3/5", "1/5", "4/5", "3/5"],
			["What is 2/3 - 1/6?", "1/6", "1/2", "1/3", "5/6", "1/2"],
			["What does LCD stand for?", "Lowest Common Divisor", "Least Common Denominator", "Levelled Common Divisor", "Lower Common Divisor", "Least Common Denominator"],
			["What is 2/2 - 1/2?", "1/2", "1/4", "3/4", "2/4", "1/2"],
			["What is 5/6 - 1/3?", "1/2", "1/3", "2/3", "5/6", "1/2"],
			["What is 3/4 - 1/4?", "2/4", "1/2", "3/4", "1", "1/2"],
			["What is 7/10 - 3/10?", "1/5", "4/10", "7/10", "1/2", "4/10"],
			["What is 3/4 - 1/2?", "1/4", "1/2", "1/3", "2/4", "1/4"]
			]
			
## Online only: the questions didn't arrive. Let the student retry or leave.
func _on_questions_failed(failed_minigame_id: int, message: String) -> void:
	if failed_minigame_id != QuestionsLoader.minigame_id:
		return
	NoticeOverlay.ask(get_tree().current_scene, "Couldn't load the questions", message, ["TRY AGAIN", "BACK TO MAP"], func(choice):
		if choice == 0:
			QuestionsLoader.reload(failed_minigame_id)
		else:
			get_tree().change_scene_to_file(Global.floor_scene()))

func _on_questions_loaded():
	if DialogueState.current_quest == "face_the_snake_post_cutscene":
		mc_questions = QuestionsLoader.snekkers_questions
		mc_choice_ids = QuestionsLoader.snekkers_choice_ids
	elif DialogueState.current_quest == "crab_boss":
		mc_questions = QuestionsLoader.crab_questions
		mc_choice_ids = QuestionsLoader.crab_choice_ids
	else:
		mc_questions = QuestionsLoader.final_boss_questions
		mc_choice_ids = QuestionsLoader.final_boss_choice_ids
	# score = questions.size() MINUS no_of_wrong_attempts
	Global.total_score = mc_questions.size()
	if is_visible_in_tree():
		_show_new_question()

# can change for better randomness using shuffle bags
func _choose_question() -> int:
	return RandomNumberGenerator.new().randi_range(0, mc_questions.size() - 1)

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_show_new_question()

func _input(event: InputEvent) -> void:
	if _locked or not is_visible_in_tree() or not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	var choice_index := [KEY_1, KEY_2, KEY_3, KEY_4].find(event.keycode)
	if choice_index == -1:
		choice_index = [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4].find(event.keycode)
	if choice_index != -1 and not choice_buttons[choice_index].disabled:
		get_viewport().set_input_as_handled()
		_on_choice_pressed(choice_index)

## Shows the student which choice they picked, green or red, then carries on as before.
## The correct choice is never revealed: a missed question stays in the pool.
func _on_choice_pressed(choice_index: int) -> void:
	if _locked or choices.size() <= choice_index:
		return
	_locked = true
	# post statistic if online
	postStatistics(choice_index)
	answer = choices[choice_index]
	var right := is_correct(answer, correct_answer)
	choice_buttons[choice_index].theme_type_variation = &"ChoiceCorrect" if right else &"ChoiceWrong"
	if right:
		correct_sfx.play()
		_set_feedback("Correct!", &"FeedbackSuccess")
	else:
		wrong_sfx.play()
		_set_feedback("Not quite. Try another question.", &"FeedbackError")
	await get_tree().create_timer(FEEDBACK_SECONDS).timeout
	_check_answer()

func _check_answer():
	if question_count == 0:
		question_count = mc_questions.size()
	#On correct answer
	if is_correct(answer, correct_answer):
		camera.apply_shake()
		visible=false
		
		#This current quest changer should be wherever the final question/end of quiz is
		
		mc_questions.remove_at(index)
		if Global.is_online:
			mc_choice_ids.remove_at(index)
		var hp: int = Global.quiz_boss_hp(mc_questions.size(), question_count)
		Global.Snekker_HP = hp
		Global.Giant_Enemy_Crab_HP = hp
		Global.guardian_enemy_hp = hp
	#On wrong answer
	else:
		if Global.is_online:
			Global.total_score -= 1

	Global.Snekker_question = false
	Global.Giant_Enemy_Crab_question = false
	Global.guardian_enemy_question = false

func _show_new_question() -> void:
	_locked = false
	_set_feedback("Press 1-4 or click an answer.", &"Feedback")
	if mc_questions == null:
		# Online questions haven't arrived yet; _on_questions_loaded fills this in.
		content.text = "Loading questions..."
		for button in choice_buttons:
			button.text = ""
			button.disabled = true
		return
	if mc_questions.is_empty():
		# A quiz with no questions can't be fought: end it rather than index an empty pool.
		Global.Snekker_HP = 0
		Global.Giant_Enemy_Crab_HP = 0
		Global.guardian_enemy_hp = 0
		visible = false
		return
	index = _choose_question()
	question = mc_questions[index]
	content.text = question[0]
	content.add_theme_font_size_override("font_size", 24 if content.text.length() <= LONG_TEXT else 16)
	choices.clear()
	for i in choice_buttons.size():
		choices.append(str(question[i + 1]))
	var longest := 0
	for choice in choices:
		longest = max(longest, choice.length())
	for i in choice_buttons.size():
		var button := choice_buttons[i]
		button.text = choice_label(i, choices[i])
		button.disabled = false
		button.theme_type_variation = &"ChoiceButton"
		button.add_theme_font_size_override("font_size", 24 if longest <= LONG_CHOICE else 16)
	correct_answer = question[5]
	choice_buttons[0].grab_focus.call_deferred()

func _set_feedback(text: String, variation: StringName) -> void:
	feedback.text = text
	feedback.theme_type_variation = variation
	
func postStatistics(choice_index):
	if Global.is_online:
		var minigame_id
		if DialogueState.current_quest == "face_the_snake_post_cutscene":
			minigame_id = 5
		elif DialogueState.current_quest == "crab_boss":
			minigame_id = 11
		else: # else, world 3 boss level
			minigame_id = 12 # 12? 
		
		Statistics.postQuizResponse(PlayerState.classroom_id, minigame_id, int(mc_questions[index][6]), PlayerState.student_id, int(mc_choice_ids[index][choice_index]))
