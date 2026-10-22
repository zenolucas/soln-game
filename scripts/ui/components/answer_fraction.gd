class_name AnswerFraction
extends VBoxContainer
## Two answer boxes stacked over a rule: the student types a numerator and a
## denominator. Only digits are accepted. Enter in the numerator moves to the
## denominator; Enter in the denominator emits `submitted`.

signal submitted

const FLASH_SECONDS := 0.6

var numerator := LineEdit.new()
var rule := ColorRect.new()
var denominator := LineEdit.new()
var _flash: Tween

func _init(max_length := 2, numerator_hint := "", denominator_hint := "") -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_constant_override("separation", 4)
	numerator.name = "Numerator"
	denominator.name = "Denominator"
	numerator.placeholder_text = numerator_hint
	denominator.placeholder_text = denominator_hint
	for box in [numerator, denominator]:
		box.theme_type_variation = &"AnswerBox"
		box.max_length = max_length
		box.alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.custom_minimum_size = Vector2(40 + 16 * max_length, 40)
		box.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		box.select_all_on_focus = true
		box.context_menu_enabled = false
		box.text_changed.connect(_digits_only.bind(box))
	rule.custom_minimum_size = Vector2(0, 2)
	rule.color = Palette.SNOW2
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(numerator)
	add_child(rule)
	add_child(denominator)
	numerator.text_submitted.connect(func(_text): denominator.grab_focus())
	denominator.text_submitted.connect(func(_text): submitted.emit())

func clear() -> void:
	numerator.clear()
	denominator.clear()

func set_editable(on: bool) -> void:
	numerator.editable = on
	denominator.editable = on

func focus_first() -> void:
	if is_inside_tree() and numerator.editable:
		numerator.grab_focus()

## Briefly outline both boxes in green ("correct") or red ("wrong").
func flash(kind: String) -> void:
	var variation := &"AnswerBoxCorrect" if kind == "correct" else &"AnswerBoxWrong"
	numerator.theme_type_variation = variation
	denominator.theme_type_variation = variation
	if not is_inside_tree():
		return
	if _flash:
		_flash.kill()
	_flash = create_tween()
	_flash.tween_interval(FLASH_SECONDS)
	_flash.tween_callback(func():
		numerator.theme_type_variation = &"AnswerBox"
		denominator.theme_type_variation = &"AnswerBox")

static func digits_only(text: String) -> String:
	var digits := ""
	for character in text:
		if character >= "0" and character <= "9":
			digits += character
	return digits

func _digits_only(new_text: String, box: LineEdit) -> void:
	var clean := digits_only(new_text)
	if clean == new_text:
		return
	var caret := box.caret_column - (new_text.length() - clean.length())
	box.text = clean
	box.caret_column = max(caret, 0)
