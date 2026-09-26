extends Node

var player_badges = {}
var current_floor: int
var current_quest: String
var saved_scene: String
var saved_position: Vector2
var first_time_initializing_first_floor_scene: bool
var first_time_initializing_second_floor_scene: bool
var first_time_initializing_third_floor_scene: bool
# auto-actionables
var rock_removed: bool = false 
var disable_rock_removed = false 
var raket_sneaking_quest_complete: bool = false 
var unlock_cave_collision: bool = false  
var raket_sword_complete: bool = false 
var raket_quest_progress: int = 0 
var do_raket_blacksmith_animation: bool = false 
var sword_bottom: bool = false
var sword_guard: bool = false
var sword_lower_blade: bool = false
var sword_middle_blade: bool = false
var sword_top_blade: bool = false
var disable_dead_robot_quest: bool
var disable_raket_stealing_quest: bool
var disable_fresh_dialogue_quest: bool
var disable_water_logged_1_quest: bool
var disable_water_logged_2_quest: bool
var disable_water_logged_3_quest: bool
var disable_chip_quest: bool
var disable_rat_wizard_training_quest: bool

signal saved_data_loaded
var load_success: bool

func _ready() -> void:
	pass # Replace with function body.

# ----------------------- LOADING SAVED DATA FROM SERVER --------------------------------

func load_save_data(student_id):
	print("load_save_data is triggered")
	var url = "http://"+ Global.host_ip +":3000/game/getsavedata"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	var post_data = {
		"student_id": student_id
	}
	
	var json_body = JSON.stringify(post_data)
	var headers = Global.auth_headers()
		
	# execute POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("error: unable to make request")

func _http_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var response = json.get_data()
			player_badges = response.player_badges
			current_floor = response.current_floor
			current_quest = response.current_quest
			saved_scene = response.saved_scene
			saved_position = Vector2(response.vector_x, response.vector_y)
			first_time_initializing_first_floor_scene = response.first_time_init_floor1
			first_time_initializing_second_floor_scene = response.first_time_init_floor2
			first_time_initializing_third_floor_scene = response.first_time_init_floor3
			
			rock_removed = response.rock_removed
			disable_rock_removed = response.disable_rock_removed
			raket_sneaking_quest_complete = response.raket_sneaking_quest_complete
			unlock_cave_collision = response.unlock_cave_collision
			raket_sword_complete = response.raket_sword_complete
			raket_quest_progress = response.raket_quest_progress
			do_raket_blacksmith_animation = response.do_raket_blacksmith_animation
			sword_bottom = response.sword_bottom
			sword_guard = response.sword_guard
			sword_lower_blade = response.sword_lower_blade
			sword_middle_blade = response.sword_middle_blade
			sword_top_blade = response.sword_top_blade
			
			disable_dead_robot_quest = response.disable_dead_robot_quest
			disable_raket_stealing_quest = response.disable_raket_stealing_quest
			disable_fresh_dialogue_quest = response.disable_fresh_dialogue_quest
			disable_water_logged_1_quest = response.disable_water_logged_1_quest
			disable_water_logged_2_quest = response.disable_water_logged_2_quest
			disable_water_logged_3_quest = response.disable_water_logged_3_quest
			disable_chip_quest = response.disable_chip_quest
			disable_rat_wizard_training_quest = response.disable_rat_wizard_training_quest
			load_success = true
			emit_signal("saved_data_loaded")
			print("SAVE DATA LOADED!!")
	else:
		print("HTTP request failed with code: error in get save data", response_code)
		load_success = false
		
		
# ----------------------- SENDING SAVED DATA TO SERVER --------------------------------

func post_save_data(save_data):
	var url = "http://"+ Global.host_ip +":3000/game/postsavedata"
	print(url)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_post_completed)
	
	var json_body = JSON.stringify(save_data)
	var headers = Global.auth_headers()
	
	# execute POST request
	print("this executes")
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("error: unable to make request")
		
# Called when the HTTP request is completed.
func _http_post_completed(_result, response_code, _headers, body):
	if response_code == 200:
		print("Saved Data Sent Successfully")
	else:
		print("HTTP request failed in SAVE STATE with code", response_code)
