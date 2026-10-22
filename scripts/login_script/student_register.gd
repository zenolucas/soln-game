extends Control

@onready var first_name: LineEdit = %FirstName
@onready var last_name: LineEdit = %LastName
@onready var username: LineEdit = %Username
@onready var class_number: LineEdit = %ClassNumber
@onready var class_section: LineEdit = %ClassSection
@onready var password: LineEdit = %Password
@onready var ip_address_input: LineEdit = %IPAddress
@onready var error_label_username: Label = %ErrorLabel
@onready var register_button: Button = %RegisterButton
@onready var http_request: HTTPRequest = HTTPRequest.new()

var register_url

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create an HTTP request node and connect its completion signal.
	http_request.timeout = 15
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	if Global.host_ip != "localhost":
		ip_address_input.text = Global.host_ip
	# Enter moves through the form in reading order and registers from the last field.
	var order: Array[LineEdit] = [ip_address_input, first_name, last_name, username, password, class_number, class_section]
	for i in order.size() - 1:
		var next_field := order[i + 1]
		order[i].text_submitted.connect(func(_t): next_field.grab_focus())
	class_section.text_submitted.connect(func(_t): _on_register_button_button_down())
	(first_name if ip_address_input.text != "" else ip_address_input).grab_focus()

func _on_register_button_button_down():
	if register_button.disabled:
		return
	for field in [ip_address_input, first_name, last_name, username, password, class_number, class_section]:
		if field.text.strip_edges() == "":
			error_label_username.text = "Fill in every field."
			field.grab_focus()
			return
	Global.host_ip = ip_address_input.text.strip_edges()
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
	_set_busy(true)
	var error = http_request.request(register_url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		_set_busy(false)
		error_label_username.text = "That server address doesn't look right. Check it and try again."

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	_set_busy(false)
	if not RequestErrors.ok(result, response_code):
		error_label_username.text = RequestErrors.describe(result, response_code, Global.host_ip)
		return
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK or not json.get_data() is Dictionary:
		error_label_username.text = "Unexpected reply from the server. Check the server address."
		return
	var response = json.get_data()
	if response.success:
		# do login if registration is successful
		get_tree().change_scene_to_file("res://scenes/student_scene/student_login.tscn")
	else:
		# show error when registration failed
		error_label_username.text = str(response.get("error_text", "Registration failed."))

func _set_busy(busy: bool) -> void:
	register_button.disabled = busy
	register_button.text = "REGISTERING..." if busy else "REGISTER"
	if busy:
		error_label_username.text = ""

func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/start_menu.tscn")
