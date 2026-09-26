extends Node

# openlabserver is 30.30.28.52
var host_ip = "localhost"
# to know if the game is on online or offline mode
var is_online = false # set to true if student logs into online mode

var current_floor = 1

# for smithing mini game
var ores_inside:int = 0

# for snekkers battle scene
var Snekker_HP = 100
var Snekker_Current_HP = 100
var Snekker_question = false
var tilemap: TileMapLayer
var total_score

# for giant enemy crab battle scene
var Giant_Enemy_Crab_HP = 100
var Giant_Enemy_Crab_Current_HP = 100
var Giant_Enemy_Crab_question = false

# for final battle
var guardian_enemy_hp = 100
var guardian_enemy_current_hp = 100
var guardian_enemy_question = false

var user_energy = 3

# tutorial
var is_simplified_tutorial: bool = false

func _process(delta: float) -> void:
	if user_energy == 0:
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
		user_energy = 3


func choose_question(question_array_size: Array) -> int:
	return RandomNumberGenerator.new().randi_range(0, question_array_size.size() - 1)


# 1st parameter: Array of questions to be chosen
# 2nd parameter: Array of chosen questions
# 3rd parameter: Track the questions that have been chosen (indices into the 1st parameter)
# Picks up to 3 distinct questions at random. A teacher can leave fewer than 3 in a scene, so this takes
# min(3, available) instead of waiting for 3, and shuffles indices so a question can't be picked twice.
func randomize_questions(questions_array: Array, current_chosen_questions: Array, chosen_index_questions: Array[int]) -> Array:
	var order := range(questions_array.size())
	order.shuffle()
	for i in order.slice(0, mini(3, questions_array.size())):
		chosen_index_questions.append(i)
		current_chosen_questions.append(questions_array[i])
	print("Current chosen index question are ", chosen_index_questions)
	return current_chosen_questions

# Every request to the teacher-module server is built here (GAME-09) from the address typed at login:
# - a full URL ("https://soln.example.com") is used as-is, so a deployed server works over HTTPS;
# - a bare host ("192.168.1.10", "localhost") means a LAN server: plain HTTP on port 3000;
# - a host with a port ("192.168.1.10:8080") means plain HTTP on that port.
func server_base_url(address: String) -> String:
	var base := address.strip_edges()
	while base.ends_with("/"):
		base = base.left(-1)
	if base.begins_with("https://") or base.begins_with("http://"):
		return base
	if not ":" in base:
		base += ":3000"
	return "http://" + base

func server_url(path: String) -> String:
	return server_base_url(host_ip) + path

# Headers for requests that read or write this student's data (the server rejects them without the token).
func auth_headers() -> PackedStringArray:
	return PackedStringArray(["Content-type: application/json", "Authorization: Bearer " + PlayerState.game_token])

# A quiz boss's HP once `remaining` of `total` questions are left: 100 at the start, exactly 0 after the
# last correct answer, whatever the quiz length (a fixed 10 per hit only works for exactly 10 questions).
func quiz_boss_hp(remaining: int, total: int) -> int:
	if total <= 0:
		return 0
	return roundi(100.0 * remaining / total)

func add_energy():
	if user_energy >= 5:
		return
	user_energy += 1
