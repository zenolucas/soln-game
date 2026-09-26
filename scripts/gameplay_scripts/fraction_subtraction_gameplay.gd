extends Control

signal correct
signal incorrect

# index 0: question, index 1: 1st numerator, index 2: 1st denominator
# index 3: 2nd numerator, index 4: 2nd denominator, index 5: index of the question

# Store multiple questions as pairs of numerators and denominators
var fraction_questions = [
	["A cauldron in the Wizard Rat’s training room was initially filled with five sixths of a glowing potion. During a practice spell, another two thirds was spilled. How much potion remains in the cauldron?", 5, 6, 2, 3, 0],
	["A crystal orb was charged with seven eighths of its total magical energy. After a surge of dark power struck the chamber, three fourths of the energy was drained. How much energy remains in the orb?", 7, 8, 3, 4, 1],
	["A spell scroll contained nine tenths of the Wizard Rat’s ancient runes. Over time, two fifths of the runes faded from the parchment. How much of the inscription remains visible?", 9, 10, 2, 5, 2],
	["A training flask was filled with four fifths of a shimmering elixir. During an experiment, one half was accidentally vaporized. How much elixir remains in the flask?", 4, 5, 1, 2, 3],
	["The Wizard Rat’s mana crystal held six sevenths of its total energy. After a draining duel with the cursed crab, two thirds of that energy was lost. How much power remains in the crystal?", 6, 7, 2, 3, 4],
	["A magical lantern glowed at three fourths of its brightness. When the dark mist spread through the corridor, one third of its light faded. How much brightness remains in the lantern?", 3, 4, 1, 3, 5],
	["A potion bottle was filled with seven ninths of a rare healing mixture. After a failed spell, four ninths of it spilled onto the floor. How much of the potion remains in the bottle?", 7, 9, 4, 9, 6],
	["A crystal bowl contained eight tenths of enchanted water. During a purification ritual, three fifths of it evaporated. How much enchanted water remains in the bowl?", 8, 10, 3, 5, 7],
	["A glowing rune stone held five eighths of its magic power. When the Wizard Rat used it for teleportation practice, one fourth of its energy was consumed. How much magic remains in the stone?", 5, 8, 1, 4, 8],
	["A beaker of luminous dust was filled to six tenths of its capacity. During a storm inside the tower, one third of it was scattered by the wind. How much dust remains in the beaker?", 6, 10, 1, 3, 9]
]

# List to store question context text for each round
var current_question_index = 0  # Track which question the player is on
@onready var num_right_ans = 0
@onready var num_wrong_ans = 0

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
var current_minigame_id = 1
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
		if DialogueState.current_quest == "wizard_training_room":
			Global.choose_question(fraction_questions)
			fraction_questions = Global.randomize_questions(fraction_questions, current_chosen_questions, chosen_index_questions)
			
		display_current_question()
	
func _on_questions_loaded():
	if DialogueState.current_quest == "wizard_training_room":
		Global.choose_question(fraction_questions)
		fraction_questions = Global.randomize_questions(QuestionsLoader.rat_questions, current_chosen_questions, chosen_index_questions)
		
	display_current_question()
	

func npc_active():
	current_npc = "default"
	if DialogueState.current_quest == "wizard_training_room" or DialogueState.current_quest == "starting":
		current_npc = "wizard_rat"
	else:
		print("No npc found!")
	npc_sprite.play(current_npc)

# Initialize questions and context texts based on the current quest
func initiate_questions():
	print(DialogueState.current_quest)
	QuestionsLoader.connect("questions_loaded", _on_questions_loaded)

	if DialogueState.current_quest == "wizard_training_room":
		print("Current quest is ", DialogueState.current_quest)
		QuestionsLoader.get_rat_questions()
		current_minigame_id = QuestionsLoader.post_data["MinigameID"]
		print("current minigame id ", current_minigame_id)
	
	else:
		print("No quest?")

# Display the current question and update the label text
func display_current_question():
	if fraction_questions.is_empty():
		# No questions for this scene: finish it instead of indexing an empty list.
		next_question_or_finish()
		return
	# reset right and wrong ans count
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
	
	print("Input matches question: ", input_matches_question(first_numerator, first_denominator, second_numerator, second_denominator))
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
		display_answer.text = "Input the fractions that you have found in their proper order."
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
	
	if first_numerator == current_question[1] and first_denominator == current_question[2] and second_numerator == current_question[3] and second_denominator == current_question[4]:
		return true
	return false

func fraction_addition_checker(first_numerator: int, first_denominator: int, second_numerator: int, second_denominator: int, answer_numerator: int, answer_denominator: int):
	# If denominators are the same, just add the numerators
	if first_denominator == second_denominator:
		var added_numerator = first_numerator - second_numerator
		
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
		var added_adjusted_numerator = adjusted_first_numerator - adjusted_second_numerator
		
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
	emit_signal("correct")
	num_right_ans += 1
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
	emit_signal("incorrect")
	num_wrong_ans += 1

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
	if DialogueState.current_quest == "wizard_training_room":
		print("Wizard training complete!")
		DialogueState.current_quest = "wizard_training_room_worded_complete"
	get_tree().change_scene_to_file("res://scenes/levels/Floor2.tscn")

# Plays when the player inputs a correct answer
func _on_correct_answer():
	$CorrectAnswerSFX.play()
	if current_npc == "wizard_rat":
		npc_sprite.play("wizard_rat_correct")
		await npc_sprite.animation_finished
		npc_sprite.play("wizard_rat")
		
# Plays when the player inputs an incorrect answer
func _on_incorrect_answer():
	Global.user_energy -= 1
	if Global.user_energy == 0 and Global.is_online:
		Statistics.post_fraction_statistics(PlayerState.classroom_id, PlayerState.student_id, current_chosen_questions[current_question_index][5], QuestionsLoader.minigame_id, num_right_ans, num_wrong_ans)
	$WrongAnswerSFX.play()
