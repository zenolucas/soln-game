extends MarginContainer

var quest_number: int

signal all_done
signal correct
signal incorrect

# question format per index in array is another array [numerator 1, denominator 1, numerator 2, denominator 2, operation]
var questions = [
	[1, 4, 1, 6, "+"],    
	[1, 3, 2, 6, "+"],    
	[2, 5, 3, 10, "+"]]

func load_default_questions():
	# place questions here
	# question format per index in array is another array [numerator 1, denominator 1, numerator 2, denominator 2, operation]
	if DialogueState.current_quest in ["water_room_1", "after_wr_1", "water_room_2", "after_wr_2", "water_room_3", "after_wr_3", "meeting_chip", "after_chip"]:
		questions = [
			[3, 4, 1, 6, "-", 0],    
			[2, 3, 1, 6, "-", 1],    
			[4, 5, 3, 10, "-", 2],   
			[5, 8, 2, 8, "-", 3],    
			[5, 7, 1, 14, "-", 4],   
			[6, 6, 2, 3, "-", 5],    
			[5, 10, 2, 5, "-", 6],   
			[4, 9, 1, 3, "-", 7],    
			[3, 4, 1, 8, "-", 8],    
			[5, 15, 2, 15, "-", 9],  
			[3, 5, 2, 10, "-", 10],
			[4, 7, 3, 14, "-", 11],   
			[5, 8, 2, 8, "-", 12],
			[6, 12, 1, 3, "-", 13],   
			[4, 10, 1, 5, "-", 14],
			[5, 9, 4, 9, "-", 15],   
			[7, 16, 2, 8, "-", 16],   
			[3, 6, 1, 12, "-", 17],   
			[6, 8, 2, 4, "-", 18],   
			[4, 5, 3, 10, "-", 19],
			[5, 6, 1, 3, "-", 20],
			[7, 10, 2, 5, "-", 21],
			[3, 8, 1, 4, "-", 22],
			[4, 9, 1, 6, "-", 23],
			[7, 12, 2, 12, "-", 24],
			[5, 7, 3, 14, "-", 25],
			[8, 15, 4, 15, "-", 26],
			[3, 5, 1, 10, "-", 27],
			[7, 8, 1, 4, "-", 28],
			[9, 10, 2, 5, "-", 29]
		]

	else:
		questions = [
				[1, 4, 1, 6, "+", 0],    
				[1, 3, 2, 6, "+", 1],    
				[2, 5, 3, 10, "+", 2],   
				[1, 8, 2, 8, "+", 3],    
				[3, 7, 1, 14, "+", 4],   
				[1, 6, 2, 3, "+", 5],    
				[3, 10, 2, 5, "+", 6],   
				[2, 9, 1, 3, "+", 7],    
				[1, 4, 3, 8, "+", 8],    
				[2, 15, 5, 15, "+", 9],  
				[1, 5, 2, 10, "+", 10],
				[1, 7, 3, 14, "+", 11],   
				[3, 8, 2, 8, "+", 12],
				[1, 12, 1, 4, "+", 13],   
				[2, 10, 1, 5, "+", 14],
				[1, 9, 4, 9, "+", 15],   
				[3, 16, 5, 8, "+", 16],   
				[1, 6, 1, 12, "+", 17],   
				[2, 8, 3, 4, "+", 18],   
				[1, 5, 3, 10, "+", 19],
				[2, 9, 4, 9, "+", 20],
				[3, 10, 1, 2, "+", 21],
				[5, 12, 3, 4, "+", 22],
				[2, 7, 3, 14, "+", 23],
				[1, 8, 5, 16, "+", 24],
				[3, 5, 1, 10, "+", 25],
				[4, 9, 2, 3, "+", 26],
				[5, 8, 1, 8, "+", 27],
				[2, 11, 3, 11, "+", 28],
				[1, 3, 1, 9, "+", 29],
			]


var current_chosen_questions: Array = []
var chosen_index_questions: Array[int] = []
var num_right_ans: int
var num_wrong_ans: int
var minigame_id

var question_index:int = 0
# numerator and denominator of first and second fraction
@onready var denum1 = $VBoxContainer/Problem/Fraction1/VBoxContainer/Denominator
@onready var num1 = $VBoxContainer/Problem/Fraction1/VBoxContainer/Numerator
@onready var denum2 = $VBoxContainer/Problem/Fraction2/VBoxContainer/Denominator
@onready var num2 = $VBoxContainer/Problem/Fraction2/VBoxContainer/Numerator
@onready var operator = $VBoxContainer/Problem/Operator/Label

# input numerator and denominator
@onready var num_input = $VBoxContainer/Problem/Answer/Fraction/Numerator/NumeratorAnswer
@onready var denum_input = $VBoxContainer/Problem/Answer/Fraction/Denominator/DenominatorAnswer

# label display for the result
@onready var result_display = $VBoxContainer/Result

@onready var submit_button = $VBoxContainer/Submit/SubmitAnswer

var user_answer: Array [int] = []
var correct_answer: Array [int] = []

func _ready() -> void:
	#Load the questions variable with placeholders for addition and subtraction
	load_default_questions()
	if Global.is_online:
		print("online mode")
		_load_questions()
	else: # else display hard coded values
		print("offline mode")
		Global.choose_question(questions)
		Global.randomize_questions(questions, current_chosen_questions, chosen_index_questions)
		_display_question()


func _load_questions():
	print("current quest is ", DialogueState.current_quest)
	QuestionsLoader.connect("questions_loaded", _on_questions_loaded)
	match DialogueState.current_quest:
		"saisai_wheelbarrow":
			QuestionsLoader.get_saisai_questions()
		"dead_robots":
			QuestionsLoader.get_robot_questions()
		"water_room_1":
			QuestionsLoader.get_water1_questions()
		"meeting_chip":
			QuestionsLoader.get_chip_questions()
		"water_room_2":
			QuestionsLoader.get_water2_questions()
		"water_room_3":
			QuestionsLoader.get_water3_questions()

func _on_questions_loaded():
	match DialogueState.current_quest:
		"saisai_wheelbarrow":
			questions = QuestionsLoader.saisai_questions
		"dead_robots":
			questions = QuestionsLoader.robot_questions
		"water_room_1":
			questions = QuestionsLoader.water1_questions
		"meeting_chip":
			questions = QuestionsLoader.chip_questions
		"water_room_2":
			questions = QuestionsLoader.water2_questions
		"water_room_3":
			questions = QuestionsLoader.water3_questions
			
	Global.choose_question(questions)
	Global.randomize_questions(questions, current_chosen_questions, chosen_index_questions)
	_display_question()


func _display_question():
	if question_index == current_chosen_questions.size():
		print("no more questions")
		_disable_questions()
		
	else :
		# reset num of right and wrong answers
		num_right_ans = 0
		num_wrong_ans = 0
		
		num_input.clear()
		denum_input.clear()
		
		num1.text = str(current_chosen_questions[question_index][0])
		denum1.text = str(current_chosen_questions[question_index][1])
		num2.text = str(current_chosen_questions[question_index][2])
		denum2.text = str(current_chosen_questions[question_index][3])
		operator.text = str(current_chosen_questions[question_index][4])

func _disable_questions():
	emit_signal("all_done")
	# THERE IS NO HELP BUTTON IN WATERLOGGED
	#help_button.visible = false
	#help_button.disabled = true
	
	num1.text = "0"
	denum1.text = "0"
	num2.text = "0"
	denum2.text = "0"
	operator.text = "0"
	
	num_input.editable = false
	denum_input.editable = false
	
	submit_button.disabled = true
	
	result_display.text = "You have answered all the questions"


func _on_submit_answer_pressed() -> void:
	correct_answer.clear()
	user_answer.clear()
	user_answer.append(int(num_input.text))
	user_answer.append(int(denum_input.text))

	match operator.text:
		"+" :
			_addition()
		"-" :
			_subtraction()

func _check_answer():
	if user_answer[1] == 0:
		result_display.text = "Zero can't be the denominator"
		num_wrong_ans += 1
		emit_signal("incorrect")
		return
	if user_answer[0] == correct_answer[0] and not user_answer[1] == correct_answer[1]:
		result_display.text = "Incorrect Denominator Try Again"
		num_wrong_ans += 1
		emit_signal("incorrect")
		return
	if not user_answer[0] == correct_answer[0] and user_answer[1] == correct_answer[1]:
		result_display.text = "Incorrect Numerator Try Again"
		num_wrong_ans += 1
		emit_signal("incorrect")
		return
	if not is_simplified():
		result_display.text = "Answer can still be simplified"
		Global.is_simplified_tutorial = true
		return
	if user_answer[0] == correct_answer[0] and user_answer[1] == correct_answer[1]:
		result_display.text = "Correct Answer"
		num_right_ans += 1
		Global.is_simplified_tutorial = false
		emit_signal("correct")
		if DialogueState.current_quest == "water_room_1" or DialogueState.current_quest == "water_room_2" or DialogueState.current_quest == "water_room_3" or DialogueState.current_quest == "meeting_chip":
			$"../CorrectSFX".play()
		if Global.is_online:
			Statistics.post_fraction_statistics(PlayerState.classroom_id, PlayerState.student_id, current_chosen_questions[question_index][5], QuestionsLoader.minigame_id, num_right_ans, num_wrong_ans)
		next()
	else:
		result_display.text = "Incorrect Answer"
		num_wrong_ans += 1
		emit_signal("incorrect")
	print(correct_answer)

func _addition():
	print("Addition")
	print(user_answer)
	
	var first_numerator = int(num1.text)
	var first_denominator = int(denum1.text)
	var second_numerator = int(num2.text)
	var second_denominator = int(denum2.text)
	
	var correct_numerator: int = 0
	var correct_denominator: int = 0
	
	# same denominator
	if first_denominator == second_denominator:
		correct_numerator = first_numerator + second_numerator
		correct_denominator = first_denominator
	
	# different denominator
	else:
		var lcd = GlobalFractionFunctions.get_lcd(first_denominator, second_denominator)
		var adjusted_first_numerator = first_numerator * (lcd / first_denominator)
		var adjusted_second_numerator = second_numerator * (lcd / second_denominator)
		correct_numerator = adjusted_first_numerator + adjusted_second_numerator
		correct_denominator = lcd
	
	var correct_fraction: Array = simplify_fraction(correct_numerator, correct_denominator)
	correct_answer.append(abs(correct_fraction[0]))
	correct_answer.append(abs(correct_fraction[1]))
	
	_check_answer()

func _subtraction():
	print("Subtraction")
	print(user_answer)
	
	var first_numerator = int(num1.text)
	var first_denominator = int(denum1.text)
	var second_numerator = int(num2.text)
	var second_denominator = int(denum2.text)
	
	var correct_numerator: int = 0
	var correct_denominator: int = 0
	
	# same denominator
	if first_denominator == second_denominator:
		correct_numerator = first_numerator - second_numerator
		correct_denominator = first_denominator
	
	# different denominator
	else:
		var lcd = GlobalFractionFunctions.get_lcd(first_denominator, second_denominator)
		var adjusted_first_numerator = first_numerator * (lcd / first_denominator)
		var adjusted_second_numerator = second_numerator * (lcd / second_denominator)
		correct_numerator = adjusted_first_numerator - adjusted_second_numerator
		correct_denominator = lcd
	
	var correct_fraction: Array = simplify_fraction(correct_numerator, correct_denominator)
	correct_answer.append(abs(correct_fraction[0]))
	correct_answer.append(abs(correct_fraction[1]))
	
	_check_answer()

func simplify_fraction(numerator: int, denominator: int):
	var gcd_value:int = GlobalFractionFunctions.gcd(numerator, denominator)
	var simplified_numerator = numerator / gcd_value
	var simplified_denominator = denominator / gcd_value
	var fraction: Array [int] = [simplified_numerator, simplified_denominator]
	return fraction

func is_simplified():
	var fraction: Array = simplify_fraction(user_answer[0], user_answer[1])
	if fraction[0] == user_answer[0] and fraction[1] == user_answer[1]:
		return true
	return false

func next():
	question_index += 1
	_display_question()


func _on_incorrect() -> void:
	Global.user_energy -= 1
	if Global.user_energy == 0 and Global.is_online:
		Global.is_simplified_tutorial = false
		Statistics.post_fraction_statistics(PlayerState.classroom_id, PlayerState.student_id, current_chosen_questions[question_index][5], QuestionsLoader.minigame_id, num_right_ans, num_wrong_ans)
	
	elif Global.user_energy == 0:
		Global.is_simplified_tutorial = false
