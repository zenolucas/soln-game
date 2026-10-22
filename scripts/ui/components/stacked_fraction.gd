class_name StackedFraction
extends VBoxContainer
## A fraction drawn as numerator over a 2px rule over denominator, like the
## equation bar in the teacher portal's in-game preview.

var numerator := Label.new()
var rule := ColorRect.new()
var denominator := Label.new()

func _init(num = "?", den = "?") -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_constant_override("separation", 4)
	for label in [numerator, denominator]:
		label.theme_type_variation = &"EquationText"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rule.custom_minimum_size = Vector2(32, 2)
	rule.color = Palette.SNOW2
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(numerator)
	add_child(rule)
	add_child(denominator)
	set_values(num, den)

func set_values(num, den) -> void:
	numerator.text = str(num)
	denominator.text = str(den)
