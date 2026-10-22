class_name FractionTextTest
extends GdUnitTestSuite

func test_prompt_matches_portal_preview() -> void:
	assert_str(FractionText.prompt(1, 4, "+", 1, 6)).is_equal("What is 1/4 + 1/6?")

func test_prompt_subtraction_uses_a_glyph_the_font_has() -> void:
	assert_str(FractionText.prompt(3, 4, "-", 1, 4)).is_equal("What is 3/4 - 1/4?")
	assert_str(FractionText.op_symbol("−")).is_equal("-")

func test_prompt_accepts_strings() -> void:
	assert_str(FractionText.prompt("2", "5", "+", "3", "10")).is_equal("What is 2/5 + 3/10?")
