extends Control

@onready var content = $container/VBoxContainer/Content
@onready var c1:Button = $"container/VBoxContainer/Answers/a/Choice 1"
@onready var c2:Button = $"container/VBoxContainer/Answers/b/Choice 2"
@onready var c3:Button = $"container/VBoxContainer/Answers/c/Choice 3"
@onready var c4:Button = $"container/VBoxContainer/Answers/d/Choice 4"
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

func _ready():
	if Global.is_online:
		print("ONLINE MODE: CURRENT QUEST IS: ", DialogueState.current_quest)
		QuestionsLoader.connect("questions_loaded", _on_questions_loaded)
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

# can change for better randomness using shuffle bags
func _choose_question() -> int:
	print(mc_questions)
	return RandomNumberGenerator.new().randi_range(0, mc_questions.size() - 1)

func _on_choice_1_pressed() -> void:
	# post statistic if online
	postStatistics(0)
	answer = c1.text
	_check_answer()
	

func _on_choice_2_pressed() -> void:
	# post statistic if online
	postStatistics(1)
	answer = c2.text
	_check_answer()
	
func _on_choice_3_pressed() -> void:
	# post statistic if online
	postStatistics(2)
	answer = c3.text
	_check_answer()
	
func _on_choice_4_pressed() -> void:
	# post statistic if online
	postStatistics(3)
	answer = c4.text
	_check_answer()
	
func _check_answer():
	if question_count == 0:
		question_count = mc_questions.size()
	#On correct answer
	if answer == correct_answer:
		correct_sfx.play()
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
		print("Incorrect answer")
		wrong_sfx.play()
		if Global.is_online:
			Global.total_score -= 1

	Global.Snekker_question = false
	Global.Giant_Enemy_Crab_question = false
	Global.guardian_enemy_question = false

func _on_draw() -> void:
	if mc_questions.is_empty():
		# A quiz with no questions can't be fought: end it rather than index an empty pool.
		Global.Snekker_HP = 0
		Global.Giant_Enemy_Crab_HP = 0
		Global.guardian_enemy_hp = 0
		visible = false
		return
	index = _choose_question()
	print("Questions: ")
	print(mc_questions)
	print("Choice IDs")
	print(mc_choice_ids)
	question = mc_questions[index]
	content.text = question[0]
	c1.text = question[1]
	c2.text = question[2]
	c3.text = question[3]
	c4.text = question[4]
	correct_answer = question[5]
	
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
