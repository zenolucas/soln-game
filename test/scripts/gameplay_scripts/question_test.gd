class_name QuestionTest
extends GdUnitTestSuite

const Question = preload("res://scripts/gameplay_scripts/question.gd")

func test_choice_labels_are_lettered_like_the_portal_preview() -> void:
	assert_str(Question.choice_label(0, "1/3")).is_equal("A. 1/3")
	assert_str(Question.choice_label(3, "Greatest Common Divisor")).is_equal("D. Greatest Common Divisor")

func test_answers_compare_by_choice_text_not_label() -> void:
	assert_bool(Question.is_correct("2/3", "2/3")).is_true()
	assert_bool(Question.is_correct("A. 2/3", "2/3")).is_false()
	assert_bool(Question.is_correct("1", 1.0)).is_true()
