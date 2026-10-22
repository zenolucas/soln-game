class_name AnswerFractionTest
extends GdUnitTestSuite

func test_digits_only_strips_everything_else() -> void:
	assert_str(AnswerFraction.digits_only("1a2-")).is_equal("12")
	assert_str(AnswerFraction.digits_only("")).is_equal("")

func test_typing_letters_is_filtered() -> void:
	var answer: AnswerFraction = auto_free(AnswerFraction.new(2))
	add_child(answer)
	answer.numerator.text = "4x"
	answer.numerator.text_changed.emit("4x")
	assert_str(answer.numerator.text).is_equal("4")
	assert_int(answer.numerator.max_length).is_equal(2)

func test_enter_in_denominator_submits() -> void:
	var answer: AnswerFraction = auto_free(AnswerFraction.new())
	add_child(answer)
	monitor_signals(answer, false)
	answer.denominator.text_submitted.emit("3")
	await assert_signal(answer).wait_until(500).is_emitted("submitted")

func test_flash_sets_then_restores_the_answer_box_style() -> void:
	var answer: AnswerFraction = auto_free(AnswerFraction.new())
	add_child(answer)
	answer.flash("wrong")
	assert_str(String(answer.numerator.theme_type_variation)).is_equal("AnswerBoxWrong")
	await await_millis(int(AnswerFraction.FLASH_SECONDS * 1000) + 200)
	assert_str(String(answer.numerator.theme_type_variation)).is_equal("AnswerBox")
