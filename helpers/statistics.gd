extends Node

var minigameID: int
var questionID: int ## ARRAY MAYBE FOR STORING MULTIPLE VALUES
var current_username: String = PlayerState.player_username
var current_url: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func post_fraction_statistics(classroom_id, student_id, question_id, minigame_id, num_right_attempts, num_wrong_attempts):
	var url = "http://"+ Global.host_ip +":3000/game/add/statistics/fraction"
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	var post_data = {
		"classroom_id": PlayerState.classroom_id,
		"student_id": PlayerState.student_id,
		"question_id": question_id,
		"minigame_id": minigame_id,
		"num_right_attempts": num_right_attempts,
		"num_wrong_attempts": num_wrong_attempts,
	}
	
	print(post_data)
	
	var json_body = JSON.stringify(post_data)
	var headers = Global.auth_headers()
	
	# execute POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("error: unable to make request")

func postQuizResponse(classroomID, minigameID, questionID, studentID, choiceID):
	var url = "http://"+ Global.host_ip +":3000/game/add/statistics/quiz/response"
	print(url)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	var post_data = {
		"ClassroomID": classroomID,
		"MinigameID": minigameID,
		"QuestionID": questionID,
		"StudentID": studentID,
		"ChoiceID": choiceID
	}
	
	var json_body = JSON.stringify(post_data)
	var headers = Global.auth_headers()
	
	# execute POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("error: unable to make request")
		
func postQuizScore(studentID, classroomID, minigameID, score):
	var url = "http://"+ Global.host_ip +":3000/game/add/statistics/quiz"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	var post_data = {
		"ClassroomID": classroomID,
		"MinigameID": minigameID,
		"StudentID": studentID,
		"Score": score
	}
	
	var json_body = JSON.stringify(post_data)
	var headers = Global.auth_headers()
	
	# execute POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("error: unable to make request")
		
# Called when the HTTP request is completed.
func _http_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		print("statistic sent successfully")
	else:
		print("HTTP request failed in STATISTICS with code", response_code)
