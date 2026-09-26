extends Node

var saisai_questions: Array = []
var robot_questions: Array = []
var racket_steal_questions: Array = []
var racket_house_questions: Array = []
var snekkers_questions: Array = []
var snekkers_choice_ids: Array = []
var water1_questions: Array = []
var chip_questions: Array = []
var water2_questions: Array = []
var water3_questions: Array = []
var rat_questions: Array = []
var crab_questions: Array = []
var crab_choice_ids: Array = []
var final_boss_questions: Array = []
var final_boss_choice_ids: Array = []

var post_data = {}
var minigame_id

signal questions_loaded

# Called when the node enters the scene tree for the first time.
# Load all the questions from the database
func _ready() -> void:
	pass
	

func get_saisai_questions():
	minigame_id = 1
	get_questions(minigame_id)

func get_robot_questions():
	minigame_id = 2
	get_questions(minigame_id)
	
func get_racket_steal_questions():
	minigame_id = 3
	get_questions(minigame_id)

func get_racket_house_questions():
	minigame_id = 4
	get_questions(minigame_id)
	
func get_snekkers_questions():
	minigame_id = 5
	get_questions(minigame_id)
	
func get_water1_questions():
	minigame_id = 6
	print("MINIGAME 6 IS TRIGGERED!!")
	get_questions(minigame_id)
	
func get_chip_questions():
	minigame_id = 7
	get_questions(minigame_id)

func get_water2_questions():
	minigame_id = 8
	get_questions(minigame_id)
	
func get_water3_questions():
	minigame_id = 9
	get_questions(minigame_id)
	
func get_rat_questions():
	minigame_id = 10
	get_questions(minigame_id)
	
func get_crab_questions():
	minigame_id = 11
	get_questions(minigame_id)

func get_final_boss_questions():
	minigame_id = 12
	get_questions(minigame_id)
	
func get_questions(minigame_id):
	post_data["MinigameID"] = minigame_id
	post_data["ClassroomID"] = PlayerState.classroom_id
	var url 

	if minigame_id == 1 || minigame_id == 2 || minigame_id == 6 || minigame_id == 7 || minigame_id == 8 || minigame_id == 9:
		url = Global.server_url("/game/getfractions")
	elif minigame_id == 3 || minigame_id == 4 || minigame_id == 10:
		url = Global.server_url("/game/getworded")
	elif minigame_id == 5 || minigame_id == 11 || minigame_id == 12:
		url = Global.server_url("/game/getmcquestions")	

	var http_request = HTTPRequest.new()
	add_child(http_request)
	# Bind this request's own minigame: another load can change the shared minigame_id before this one returns.
	http_request.request_completed.connect(self._http_request_completed.bind(minigame_id))

	var json_body = JSON.stringify(post_data)
	var headers = ["Content-type: application/json"]

	# execute POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("error: unable to make request")
		
# Called when the HTTP request is completed.
func _http_request_completed(_result, response_code, _headers, body, requested_minigame_id):
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var response = json.get_data()
			if requested_minigame_id == 1:
				saisai_questions = constructFractionQuestions(response, "+")
			elif requested_minigame_id == 2:
				robot_questions = constructFractionQuestions(response, "+")
			elif requested_minigame_id == 3:
				racket_steal_questions = constructWordedQuestions(response)
			elif requested_minigame_id == 4:
				racket_house_questions = constructWordedQuestions(response)
			elif requested_minigame_id == 5:
				snekkers_questions = constructQuizQuestions(response)
				snekkers_choice_ids = getChoiceIDs(response)
			elif requested_minigame_id == 6:
				water1_questions = constructFractionQuestions(response, "-")
			elif requested_minigame_id == 7:
				chip_questions = constructFractionQuestions(response, "-")
			elif requested_minigame_id == 8:
				water2_questions = constructFractionQuestions(response, "-")
			elif requested_minigame_id == 9:
				water3_questions = constructFractionQuestions(response, "-")
			elif requested_minigame_id == 10:
				rat_questions = constructWordedQuestions(response)
			elif requested_minigame_id == 11:
				crab_questions = constructQuizQuestions(response)
				crab_choice_ids = getChoiceIDs(response)
			elif requested_minigame_id == 12:
				final_boss_questions = constructQuizQuestions(response)
				final_boss_choice_ids = getChoiceIDs(response)
			
			emit_signal("questions_loaded")
	else:
		print("HTTP request failed with code: error in get fractions", response_code)

func constructFractionQuestions(response, operation):
	var questions = []
	for i in range(response.size()):
		var fraction = response[i]
		questions.append([fraction["fraction1_numerator"], fraction["fraction1_denominator"],
									fraction["fraction2_numerator"], fraction["fraction2_denominator"],
									operation, fraction["question_id"]])
	return questions
	
	
func constructWordedQuestions(response):
	var questions = []
	for i in range(response.size()):
		var fraction = response[i]
		questions.append([fraction["question_text"], fraction["fraction1_numerator"],
									fraction["fraction1_denominator"], fraction["fraction2_numerator"],
									fraction["fraction2_denominator"], fraction["question_id"]])
	return questions

func constructQuizQuestions(response):
	var questions = []
	for i in range(response.size()):
		var question = response[i]
		
		# first extract correct answer
		var correctAnswer
		correctAnswer = getCorrectAnswer(question)
		
		questions += [[
			question["question_text"], 
			question["choices"][0]["choice_text"],
			question["choices"][1]["choice_text"], 
			question["choices"][2]["choice_text"], 
			question["choices"][3]["choice_text"], 
			correctAnswer,
			question["question_id"]
			]]
			
	print(questions)

	return questions

# helper function for constructQuizQuestions
func getCorrectAnswer(question):
	var correctAnswer

	for i in range(4):
		if (question["choices"][i]["is_correct"] == true):
			return question["choices"][i]["choice_text"]
			
func getChoiceIDs(response):
	var choiceIDs = []
	for i in range(response.size()):
		var question = response[i]
		
		choiceIDs += [[
			question["choices"][0]["choice_id"],
			question["choices"][1]["choice_id"], 
			question["choices"][2]["choice_id"], 
			question["choices"][3]["choice_id"], 
			]]
			
	#print("when retrieving, choiceIDs are", choiceIDs)
		
	return choiceIDs
