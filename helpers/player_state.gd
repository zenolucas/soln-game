extends Node

# For saving states
var first_time_initializing_first_floor_scene: bool = true
var first_time_initializing_second_floor_scene: bool = true
var first_time_initializing_third_floor_scene: bool = true
var saved_position: Vector2
var saved_scene: String = "res://scenes/levels/Floor1.tscn"
var player_in_dialogue: bool = false
# player details
var player_username: String = "Sol'n"
var classroom_id = 1
var student_id = 3
# Issued by /game/login; sent back as a Bearer token on save and statistics requests.
var game_token: String = ""

var player_badges = {
	"shiny_rock": false,
	"bowl": false,
	"carrot": false,
	"cake": false,
	"sword": false,
	"mushroom": false,
	"bucket1": false,
	"flask": false,
	"bucket2": false,
	"bucket3": false,
	"crystal_ball": false,
	"shell": false,
	"original_robot": false
}

func save_player_state(position: Vector2, current_scene: String):
	saved_position = position
	saved_scene = current_scene

# First argument: where you wanna gonotification
# Second argument: where you are
func save_player_position_and_change_scene(new_scene: String, current_scene: String):
	if current_scene == "res://scenes/levels/Floor1.tscn":
		first_time_initializing_first_floor_scene = false
	elif current_scene == "res://scenes/levels/Floor2.tscn":
		first_time_initializing_second_floor_scene = false
	elif current_scene == "res://scenes/levels/Floor3.tscn":
		first_time_initializing_third_floor_scene = false
	# Assuming you have a reference to the player node in the current scene
	var current1_scene = get_tree().current_scene
	var player_node = current1_scene.get_node("MainCharacter")  # Adjust this path to match your scene tree
	if player_node:
		print("Player node found")
		saved_position = player_node.get_player_position()  # Call the function from Player.gd
		saved_scene = current_scene  # Save the current scene
		print("Current scene: ",current_scene)
		change_scene(new_scene)
	else:
		print("Player node not found")

func change_scene(new_scene: String):
	print("Changing to new scene: ", new_scene)
	get_tree().change_scene_to_file(new_scene)

func boss_gameplay():
	get_tree().change_scene_to_file("res://scenes/gameplay_scenes/battle.tscn")
	
func change_scene_to_floor2():
	get_tree().change_scene_to_file("res://scenes/levels/Floor2.tscn")

func change_scene_to_floor3():
	get_tree().change_scene_to_file("res://scenes/levels/Floor3.tscn")
	

func _ready() -> void:
	# to deal with abrupt quitting before sending saved data
	get_tree().auto_accept_quit = false

#EXIT LISTENER ON NOTIFICATION == 1006
func _notification(notification) -> void:
	if notification == 1006:
		var current_scene_before_exit =  get_tree().current_scene
		var current_player_node = current_scene_before_exit.get_node("MainCharacter")
		print("Player node found")
		saved_position = current_player_node.get_player_position()  # Call the function from Player.gd
		print("Current scene: ", saved_scene)
		print("Current position: ", saved_position)
		
		# ADD VARIABLES TO SAVE HERE
		var save_data = {
			"student_id": student_id,
			"player_badges": player_badges,
			"current_floor": Global.current_floor,
			"current_quest": DialogueState.current_quest,
			"saved_scene": saved_scene,
			"vector_x": saved_position.x,
			"vector_y": saved_position.y,
			
			# add auto actionalble variables here
			"rock_removed": DialogueState.rock_removed,
			"disable_rock_removed": DialogueState.disable_rock_removed,
			"raket_sneaking_quest_complete": DialogueState.raket_sneaking_quest_complete,
			"unlock_cave_collision": DialogueState.unlock_cave_collision,
			"raket_sword_complete": DialogueState.raket_sword_complete,
			"raket_quest_progress": DialogueState.raket_quest_progress,
			"do_raket_blacksmith_animation": DialogueState.do_raket_blacksmith_animation,
			"sword_bottom": DialogueState.sword_bottom,
			"sword_guard": DialogueState.sword_guard,
			"sword_lower_blade": DialogueState.sword_lower_blade,
			"sword_middle_blade": DialogueState.sword_middle_blade,
			"sword_top_blade": DialogueState.sword_top_blade,
			
			"disable_dead_robot_quest": DialogueState.disable_dead_robot_quest,
			"disable_raket_stealing_quest": DialogueState.disable_raket_stealing_quest,
			"disable_fresh_dialogue_quest": DialogueState.disable_fresh_dialogue_quest,
			"disable_water_logged_1_quest": DialogueState.disable_water_logged_1_quest,
			"disable_water_logged_2_quest": DialogueState.disable_water_logged_2_quest,
			"disable_water_logged_3_quest": DialogueState.disable_water_logged_3_quest,
			"disable_chip_quest": DialogueState.disable_chip_quest,
			"disable_rat_wizard_training_quest": DialogueState.disable_rat_wizard_training_quest
		}

		##part where you write the player stuff onto the database
		# Without a successful load this is the default state, not the student's: posting it would
		# overwrite their real save.
		if Global.is_online and not SaveState.load_success:
			print("Not saving: this session's save never loaded")
		elif Global.is_online:
			print("curently saving... ")
			print(save_data)
			SaveState.post_save_data(save_data)
			# some delay to send saved data to server
			await get_tree().create_timer(1.0).timeout
		print("Exiting game")
		get_tree().quit()
			
