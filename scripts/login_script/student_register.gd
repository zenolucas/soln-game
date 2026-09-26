extends Control

@onready var first_name = $StudentInformation/FirstName
@onready var last_name = $StudentInformation/LastName
@onready var username = $StudentInformation/Username
@onready var class_number = $StudentInformation/ClassNumber
@onready var class_section = $StudentInformation/ClassSection
@onready var password = $StudentInformation/Password
@onready var http_request: HTTPRequest = HTTPRequest.new()
@onready var ip_address_input = $StudentInformation/IPAddress
@onready var error_label_username = $ErrorLabelUsername

var register_url

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create an HTTP request node and connect its completion signal.
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)


func _on_register_button_button_down():
	print("Current IP address: ", ip_address_input.text)
	Global.host_ip = ip_address_input.text
	register_url = Global.server_url("/game/register")
	
	var credentials = {
		"firstname": first_name.text,
		"lastname": last_name.text,
		"username": username.text,
		"section": class_section.text,
		"classnumber": class_number.text,
		"password": password.text,
	}

	var json_body = JSON.stringify(credentials)
	var headers = ["Content-type: application/json"]
	
	# Perform a POST request. Rhe URL registers the input of the student to the database
	http_request.request(register_url, headers, HTTPClient.METHOD_POST, json_body)

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var response = json.get_data()
			print("Response: ", response.success)
			if response.success:
				# do login if registration is successful
				print("Registration successful")
				get_tree().change_scene_to_file("res://scenes/student_scene/student_login.tscn")
			else:
				# show error when registration failed
				var error_text = response.error_text
				error_label_username.text = response.error_text
				print("Registration failed")
		else:
			print("Failed to parse JSON")
	else:
		print("HTTP request failed with code:", response_code)


func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/start_menu.tscn")
