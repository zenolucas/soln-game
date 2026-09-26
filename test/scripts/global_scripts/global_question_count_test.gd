# Regression tests for GAME-05: the game has to cope with however many questions a teacher leaves in a scene.
class_name GlobalQuestionCountTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# Online-shaped questions: index 5 is the question_id (see QuestionsLoader.constructFractionQuestions).
func _questions(n: int) -> Array:
	var out := []
	for i in range(n):
		out.append([1, 2, 1, 3, "+", 100 + i])
	return out

func _pick(n: int, online: bool) -> Array:
	var was_online = Global.is_online
	Global.is_online = online
	var chosen: Array = []
	var chosen_index: Array[int] = []
	var result := Global.randomize_questions(_questions(n), chosen, chosen_index)
	Global.is_online = was_online
	return result

# Before the fix, fewer than 3 questions made randomize_questions loop forever (the run hangs).
func test_picks_min_of_three_and_available() -> void:
	for online in [true, false]:
		for n in [0, 1, 2, 3, 10]:
			var picked := _pick(n, online)
			assert_int(picked.size()).override_failure_message("n=%d online=%s" % [n, online]).is_equal(mini(3, n))

func test_picked_questions_are_distinct() -> void:
	for _i in range(20):
		var ids := {}
		for q in _pick(10, true):
			ids[q[5]] = true
		assert_int(ids.size()).is_equal(3)

func test_quiz_boss_hp_ten_questions_matches_old_behaviour() -> void:
	# The old fixed 10 damage per hit: 100, 90, ..., 0.
	for remaining in range(11):
		assert_int(Global.quiz_boss_hp(remaining, 10)).is_equal(remaining * 10)

func test_quiz_boss_hp_any_length_ends_at_zero() -> void:
	for total in [1, 3, 7, 12, 25]:
		assert_int(Global.quiz_boss_hp(total, total)).is_equal(100)
		assert_int(Global.quiz_boss_hp(0, total)).is_equal(0)
		var previous := 101
		for remaining in range(total, -1, -1):
			var hp: int = Global.quiz_boss_hp(remaining, total)
			assert_bool(hp < previous).override_failure_message("total=%d remaining=%d hp=%d" % [total, remaining, hp]).is_true()
			previous = hp

func test_quiz_boss_hp_no_questions() -> void:
	assert_int(Global.quiz_boss_hp(0, 0)).is_equal(0)

func test_offline_shaped_questions_have_no_id_column() -> void:
	# The game's built-in offline questions are 5 elements long, e.g. [1, 4, 1, 6, "+"] - no question_id.
	var offline := [[1, 4, 1, 6, "+"], [1, 3, 2, 6, "+"], [2, 5, 3, 10, "+"], [1, 2, 1, 4, "+"]]
	var chosen: Array = []
	var chosen_index: Array[int] = []
	assert_int(Global.randomize_questions(offline, chosen, chosen_index).size()).is_equal(3)
