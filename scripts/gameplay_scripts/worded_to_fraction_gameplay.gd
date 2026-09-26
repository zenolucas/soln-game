extends Control

signal correct
signal incorrect

# index 0: question, index 1: 1st numerator, index 2: 1st denominator
# index 3: 2nd numerator, index 4: 2nd denominator, index 5: index of the question

# Store multiple questions as pairs of numerators and denominators
var fraction_questions = [
	["Raket practiced his ninja skills by slicing a pie into ten pieces. He took four pieces during training and two more afterward. How much of the pie did Raket take in total?", 4, 10, 2, 10, 0],
	["During stealth training, Raket found two pies. The first was sliced into eight pieces, and he took three. The second was sliced into twelve pieces, and he took four. How much pie did Raket take altogether?", 3, 8, 4, 12, 1],
	["Raket grabbed two pies to test his speed. The first had six slices, and he took five. The second had nine slices, and he took three. How much pie did Raket take in all?", 5, 6, 3, 9, 2],
	["Robot caught Raket trying to sneak two slices of pie. One pie had eight pieces, and Raket already ate three. The other pie had ten pieces, and he ate two. How much pie did Raket eat in total?", 3, 8, 2, 10, 3],
	["While sneaking through the kitchen, Raket spotted two fruit pies. The first was divided into twelve pieces, and he took four. The second was divided into six, and he took two. How much pie did Raket take together?", 4, 12, 2, 6, 4],
	["As part of his ninja lesson, Raket used pie crusts to practice cutting quietly. One crust was divided into four parts, and he used one. Another crust was divided into eight parts, and he used three. How much crust did he use in total?", 1, 4, 3, 8, 5],
	["Robot challenged Raket with two training pies. The first was sliced into nine pieces, and Raket ate three. The second was sliced into six pieces, and he ate two. How much pie did he eat together?", 3, 9, 2, 6, 6],
	["Raket tried hiding two pies before Robot could see him. One pie was sliced into six pieces, and he took two. The other was sliced into twelve, and he took four. How much pie did Raket take altogether?", 2, 6, 4, 12, 7],
	["Raket was caught by Robot holding two half-eaten pies. The first had eight slices, and he ate three. The second had ten slices, and he ate two. How much pie did he eat in total?", 3, 8, 2, 10, 8],
	["After realizing his mistake, Raket returned the pies he took. One pie had twelve slices, and he gave back five. Another had nine slices, and he returned four. How much pie did Raket return in total?", 5, 12, 4, 9, 9]
]
	
var fraction_questions_house = [
	["Raket and Robot shared a pie that was sliced into ten pieces. Raket took four pieces of the pie, while Robot took three pieces. How much pie will they eat together?", 4, 10, 3, 10, 0],
	["Raket had a pie sliced into ten pieces and ate six for breakfast and lunch. For dinner, Raket set aside two for him and one for Robot. How much pie was saved for Robots and Rakets dinner?", 2, 10, 1, 10, 1],
	["Saisai prepared the pie you delivered so you could give it to Raket. Saisai suggested that you can eat five of the pie while Raket can eat the remaining five pieces. How much pie was eaten in total?", 5, 10, 5, 10, 2],
	["Robot baked a new pie and cut it into eight slices. He ate three slices in the morning and one slice in the afternoon. How much of the pie did he eat that day?", 3, 8, 1, 8, 3],
	["Saisai brought a pie that was cut into twelve pieces. She gave four pieces to Raket and three pieces to Robot. How much of the pie was given away in total?", 4, 12, 3, 12, 4],
	["Saisai and Robot were baking together that has a total of four crusts. Saisai used one of the pie crust for one pie and another one for another. How much crust did Raket use in total?", 1, 4, 1, 4, 5],
	["Saisai had group the pie into two group one pie has a total of three cuts while the other has six. She decided give one piece of the first pie to Robot while two piece of the second pie to Raket. How much pie did they both receive?", 1, 3, 2, 6, 6],
	["Robot sliced a pie into six equal parts. He ate two slices during lunch and one slice for dessert. How much of the pie did he eat in all?", 2, 6, 1, 6, 7],
	["Saisai baked a strawberry pie cut into eight slices. Raket took three slices, and Saisai took two slices. How much pie did they eat together?", 3, 8, 2, 8, 8],
	["Raket decided to share his pie cut into twelve slices. He gave four slices to Saisai and two slices to Robot. How much of the pie did he give away in total?", 4, 12, 2, 12, 9]
]

 # List to store question context text for each round
var current_question_index = 0  # Track which question the player is on
@onready var num_right_ans = 0
@onready var num_wrong_ans = 0
@onready var unsimplified_ans_count = 0

# Nodes for user inputs and display
@onready var first_fraction_numerator: LineEdit = $solution/first_fraction/VBoxContainer/Numerator/NumeratorAnswer
@onready var first_fraction_denominator: LineEdit = $solution/first_fraction/VBoxContainer/Denominator/DenominatorAnswer
@onready var second_fraction_numerator: LineEdit = $solution/second_fraction/VBoxContainer/Numerator/NumeratorAnswer
@onready var second_fraction_denominator: LineEdit = $solution/second_fraction/VBoxContainer/Denominator/DenominatorAnswer
@onready var numerator_answer: LineEdit = $solution/answer/VBoxContainer/Numerator/NumeratorAnswer
@onready var denominator_answer: LineEdit = $solution/answer/VBoxContainer/Denominator/DenominatorAnswer
@onready var display_answer: Label = $DisplayAnswer/UserAnswer
@onready var submit_answer = $SubmitAnswer
@onready var question_label: Label = $question/MarginContainer/Label  # Label to display question text

@onready var npc_sprite = $NPC_Sprites

var is_simplified = false
var current_player_username = PlayerState.player_username
var current_minigame_id = 1 # PLACEHOLDER
var current_npc = ""
var current_chosen_questions: Array = []
var chosen_index_questions: Array[int] = []

func _ready():
	npc_active()
	
	if Global.is_online:
		print("online mode")
		initiate_questions() # get questions from db
	
	else: # else get offline questions
		print("offline mode")
		print("Current quest is ", DialogueState.current_quest)
		if DialogueState.current_quest == "raket_stealing":
			Global.choose_question(fraction_questions)
			fraction_questions = Global.randomize_questions(fraction_questions, current_chosen_questions, chosen_index_questions)
			
		if DialogueState.current_quest == "raket_house":
			Global.choose_question(fraction_questions_house)
			fraction_questions = Global.randomize_questions(fraction_questions_house, current_chosen_questions, chosen_index_questions)
			
		display_current_question()
	
func _on_questions_loaded():
	if DialogueState.current_quest == "raket_stealing":
		Global.choose_question(fraction_questions_house)
		fraction_questions = Global.randomize_questions(QuestionsLoader.racket_steal_questions, current_chosen_questions, chosen_index_questions)
		
	
	elif DialogueState.current_quest == "raket_house":
		Global.choose_question(fraction_questions_house)
		fraction_questions = Global.randomize_questions(QuestionsLoader.racket_house_questions, current_chosen_questions, chosen_index_questions)
		
		
	display_current_question()
	

func npc_active():
	current_npc = "default"
	if DialogueState.current_quest == "share_pie_with_raket" or DialogueState.current_quest == "raket_house":
		current_npc = "raket"
	elif DialogueState.current_quest == "raket_stealing":
		current_npc = "masked_figure"
	else:
		print("No npc found!")
	npc_sprite.play(current_npc)

# Initialize questions and context texts based on the current quest
func initiate_questions():
	print(DialogueState.current_quest)
	QuestionsLoader.connect("questions_loaded", _on_questions_loaded)

	if DialogueState.current_quest == "raket_stealing":
		print("Current quest is raket stealing")
		QuestionsLoader.get_racket_steal_questions()
		current_minigame_id = QuestionsLoader.post_data["MinigameID"]
		print("current minigame id ", current_minigame_id)
	
	elif DialogueState.current_quest == "raket_house":
		QuestionsLoader.get_racket_house_questions()
		print("Current quest is raket house")
		current_minigame_id = QuestionsLoader.post_data["MinigameID"]
		fraction_questions = fraction_questions_house
	else:
		print("No quest?")

# Display the current question and update the label text
func display_current_question():
	if fraction_questions.is_empty():
		# No questions for this scene: finish it instead of indexing an empty list.
		next_question_or_finish()
		return
	# reset right and wrong answer count
	num_right_ans = 0
	num_wrong_ans = 0
	
	print(fraction_questions[current_question_index])
	var current_question = fraction_questions[current_question_index]
	#var first_fraction = current_question[0]
	#var second_fraction = current_question[1]
	
	# Set the text for the fractions to be input by the player
	first_fraction_numerator.text = ""
	first_fraction_denominator.text = ""
	second_fraction_numerator.text = ""
	second_fraction_denominator.text = ""
	numerator_answer.text = ""
	denominator_answer.text = ""
	
	# Set the question text for the current round
	question_label.text = current_question[0]

# Called when the submit answer button is pressed
func _on_submit_answer_button_down():
	# Retrieve input values
	var first_numerator = int(first_fraction_numerator.text)
	var first_denominator = int(first_fraction_denominator.text)
	var second_numerator = int(second_fraction_numerator.text)
	var second_denominator = int(second_fraction_denominator.text)
	var answer_numerator = int(numerator_answer.text)
	var answer_denominator = int(denominator_answer.text)

	# Validate the inputted fractions against the question
	if input_matches_question(first_numerator, first_denominator, second_numerator, second_denominator):
		# Check if the inputs are empty
		if numerator_answer.text == "" or denominator_answer.text == "":
			display_answer.text = "Please fill in both the numerator and denominator."
			num_wrong_ans += 1
			emit_signal("incorrect")
			print("Empty input detected.")
			return  # Exit the function if any input is empty
		
		# Validate the numerator and denominator inputs
		elif !is_valid_integer(numerator_answer.text) or !is_valid_integer(denominator_answer.text):
			display_answer.text = "Please enter valid numbers."
			num_wrong_ans += 1
			emit_signal("incorrect")
			print("Invalid input detected: Non-integer value entered.")
			return  # Exit the function if input is invalid
			
		else:
			# Check the user's input against the current question
			fraction_addition_checker(first_numerator, first_denominator, second_numerator, second_denominator, answer_numerator, answer_denominator)
		
	elif !input_matches_question(first_numerator, first_denominator, second_numerator, second_denominator):
		display_answer.text = "Incorrect fractions. Please input the correct fractions."
		num_wrong_ans += 1
		emit_signal("incorrect")


# Helper function to check if a string is a valid integer
func is_valid_integer(value: String) -> bool:
	# Try converting the string to an integer, and return true if successful
	var number = value.to_int()
	return str(number) == value.strip_edges()


# Validate if inputted fractions match the current question's fractions
func input_matches_question(first_numerator: int, first_denominator: int, second_numerator: int, second_denominator: int) -> bool:
	var current_question = fraction_questions[current_question_index]
	#var expected_first_fraction = current_question[0]
	#var expected_second_fraction = current_question[1]
	print("im in input_matches_question")
	
	if first_numerator == current_question[1] and first_denominator == current_question[2] and second_numerator == current_question[3] and second_denominator == current_question[4]:
		print("input first")
		return true
	elif first_numerator == current_question[3] and first_denominator == current_question[4] and second_numerator == current_question[1] and second_denominator == current_question[2]:
		print("print second")
		return true
	
	return false

func fraction_addition_checker(first_numerator: int, first_denominator: int, second_numerator: int, second_denominator: int, answer_numerator: int, answer_denominator: int):
	# If denominators are the same, just add the numerators
	if first_denominator == second_denominator:
		var added_numerator = first_numerator + second_numerator
		
		if is_simplified:
			if check_simplified_form(added_numerator, first_denominator):
				handle_correct("Nice! \nCorrect simplified form.")
				is_simplified = false
				
			else:
				handle_incorrect("Try again. \nCheck your GCD value.")
				is_simplified = true
		
		elif added_numerator == answer_numerator and first_denominator == answer_denominator:
			if GlobalFractionFunctions.check_lowest_form(added_numerator, int(denominator_answer.text)):
				handle_correct_unsimplified("Good job! \nBut answer can be simplified.")
				is_simplified = true
				
			else:
				handle_correct("Great job! \nCorrect answer!")
		
		elif check_simplified_form(added_numerator, first_denominator) and !is_simplified:
			handle_correct("Advanced thinking! \nYou entered its simplified form.")
		
		else:
			handle_incorrect("Try again. Check your numerator\n or denominator.")

	# If denominators are different, find the least common denominator (LCD)
	else:
		var lcd = GlobalFractionFunctions.get_lcd(first_denominator, second_denominator)
		
		# Adjust the numerators to the same denominator
		var adjusted_first_numerator = first_numerator * (lcd / first_denominator)
		var adjusted_second_numerator = second_numerator * (lcd / second_denominator)
		var added_adjusted_numerator = adjusted_first_numerator + adjusted_second_numerator
		
		if is_simplified:
			if check_simplified_form(added_adjusted_numerator, lcd):
				handle_correct("Nice! \nCorrect simplified form.")
				is_simplified = false
				
			else:
				handle_incorrect("Try again. \nCheck your GCD value.")
				is_simplified = true
		
		elif added_adjusted_numerator == answer_numerator and lcd == answer_denominator:
			if GlobalFractionFunctions.check_lowest_form(added_adjusted_numerator, int(denominator_answer.text)):
				handle_correct_unsimplified("Good job! \nBut answer can be simplified.")
				is_simplified = true
				
			else:
				handle_correct("Great job! \nCorrect answer!")
		
		elif check_simplified_form(added_adjusted_numerator, lcd) and !is_simplified:
			handle_correct("Advanced thinking! \nYou entered its simplified form.")
			
		else:
			handle_incorrect("Try again. Check your numerator\n or denominator.")

# Handle correct answer
func handle_correct(message: String):
	display_answer.text = message
	num_right_ans += 1
	emit_signal("correct")
	if Global.is_online:
		Statistics.post_fraction_statistics(PlayerState.classroom_id, PlayerState.student_id, current_chosen_questions[current_question_index][5], QuestionsLoader.minigame_id, num_right_ans, num_wrong_ans)
	next_question_or_finish() # Move to the next question or finish the exercise

# Handle correct unsimplified answer
func handle_correct_unsimplified(message: String):
	display_answer.text = message
	emit_signal("correct")

# Handle incorrect answer
func handle_incorrect(message: String):
	display_answer.text = message
	num_wrong_ans += 1
	emit_signal("incorrect")

# Function to check for the simplified answer
func check_simplified_form(correct_numerator: int, correct_denominator: int) -> bool:
	var gcd_value: int = GlobalFractionFunctions.gcd(correct_numerator, correct_denominator)

	var simplified_numerator = correct_numerator / gcd_value
	var simplified_denominator = correct_denominator / gcd_value

	if simplified_numerator == int(numerator_answer.text) and simplified_denominator == int(denominator_answer.text):
		return true
		
	return false

# Move to the next question or finish the exercise
func next_question_or_finish():
	if current_question_index < fraction_questions.size() - 1:
		current_question_index += 1  # Move to the next question
		display_current_question()  # Update the UI with the next question
	else:
		disable_inputs()
		question_label.text = "All questions completed!\nReturning to the world..."
		await get_tree().create_timer(3.0).timeout
		return_to_world()

# Disabling inputs
func disable_inputs():
	numerator_answer.editable = false
	denominator_answer.editable = false
	first_fraction_numerator.editable = false
	first_fraction_denominator.editable = false
	second_fraction_numerator.editable = false
	second_fraction_denominator.editable = false
	submit_answer.disabled = true

# Return to the world scene
func return_to_world():
	print("Returning")
	if DialogueState.current_quest == "raket_stealing":
		DialogueState.current_quest = "raket_stealing_gameplay_done"
	if DialogueState.current_quest == "raket_house":
		print("IGHDSAD UIHASDUHASD")
		DialogueState.current_quest = "raket_house_worded_complete"
	get_tree().change_scene_to_file("res://scenes/levels/Floor1.tscn")

# Plays when the player inputs a correct answer
func _on_correct_answer():
	$CorrectAnswerSFX.play()
	if current_npc == "raket":
		npc_sprite.play("raket_correct")
		await npc_sprite.animation_finished
		npc_sprite.play("raket")
	elif current_npc == "masked_figure":
		npc_sprite.play("masked_figure_correct")
		await npc_sprite.animation_finished
		npc_sprite.play("masked_figure")

# Plays when the player inputs an incorrect answer
func _on_incorrect_answer():
	Global.user_energy -= 1
	if Global.user_energy == 0 and Global.is_online:
		Statistics.post_fraction_statistics(PlayerState.classroom_id, PlayerState.student_id, current_chosen_questions[current_question_index][5], QuestionsLoader.minigame_id, num_right_ans, num_wrong_ans)

	
	$WrongAnswerSFX.play()
	if current_npc == "raket":
		npc_sprite.play("raket_wrong")
		await npc_sprite.animation_finished
		npc_sprite.play("raket")
	elif current_npc == "masked_figure":
		npc_sprite.play("masked_figure_wrong")
		await npc_sprite.animation_finished
		npc_sprite.play("masked_figure")
