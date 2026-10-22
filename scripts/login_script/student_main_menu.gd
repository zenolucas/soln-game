extends Control

@onready var username: LineEdit = %Username
@onready var password: LineEdit = %Password
@onready var ip_address_input: LineEdit = %IPAddress
@onready var error_label: Label = %ErrorLabel
@onready var login_button: Button = %LoginButton
@onready var http_request: HTTPRequest = HTTPRequest.new()

var login_url

func _ready():
	# Create an HTTP request node and connect its completion signal.
	http_request.timeout = 15
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	if Global.host_ip != "localhost":
		ip_address_input.text = Global.host_ip
	# Enter moves down the form and logs in from the last field.
	ip_address_input.text_submitted.connect(func(_t): username.grab_focus())
	username.text_submitted.connect(func(_t): password.grab_focus())
	password.text_submitted.connect(func(_t): _on_login_button_button_down())
	(username if ip_address_input.text != "" else ip_address_input).grab_focus()

func _on_login_button_button_down():
	if login_button.disabled:
		return
	for field in [ip_address_input, username, password]:
		if field.text.strip_edges() == "":
			_show_error("Fill in the server, your username and your password.")
			field.grab_focus()
			return
	Global.host_ip = ip_address_input.text.strip_edges()
	login_url = Global.server_url("/game/login")
	
	var credentials = {
		"username": username.text,
		"password": password.text
	}
	
	var json_body = JSON.stringify(credentials)
	var headers = ["Content-type: application/json"]
	
	_set_busy(true)
	var error = http_request.request(login_url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		_set_busy(false)
		_show_error("That server address doesn't look right. Check it and try again.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	_set_busy(false)
	if not RequestErrors.ok(result, response_code):
		_show_error(RequestErrors.describe(result, response_code, Global.host_ip))
		return
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK or not json.get_data() is Dictionary:
		_show_error("Unexpected reply from the server. Check the server address.")
		return
	var response = json.get_data()
	if response.success:
		PlayerState.player_username = username.text
		Global.is_online = true
		PlayerState.classroom_id = response.classroom_id
		PlayerState.student_id = response.student_id
		PlayerState.game_token = response.get("token", "")
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	else:
		_show_error(str(response.get("error_text", "Login failed.")))
		password.grab_focus()

func _set_busy(busy: bool) -> void:
	login_button.disabled = busy
	login_button.text = "LOGGING IN..." if busy else "LOG IN"
	if busy:
		error_label.text = ""

func _show_error(message: String) -> void:
	error_label.text = message

func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/start_menu.tscn")
