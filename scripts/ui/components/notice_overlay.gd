class_name NoticeOverlay
extends Control
## A small modal card over a dimmed screen: a title, a message and one or more
## buttons. Built in code so any scene can raise one, e.g. when questions fail to load.

signal chosen(index: int)

## Shows a notice on top of `host` and calls `on_choice` with the index of the
## button pressed. The notice frees itself afterwards.
static func ask(host: Node, title: String, message: String, buttons: Array, on_choice: Callable) -> NoticeOverlay:
	var notice := NoticeOverlay.new()
	notice._build(title, message, buttons)
	notice.chosen.connect(on_choice)
	host.add_child(notice)
	return notice

func _build(title: String, message: String, buttons: Array) -> void:
	name = "Notice"
	top_level = true
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := Panel.new()
	dim.theme_type_variation = &"Dim"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card := PanelContainer.new()
	card.theme_type_variation = &"Card"
	center.add_child(card)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(448, 0)
	box.add_theme_constant_override("separation", 16)
	card.add_child(box)
	var title_label := Label.new()
	title_label.theme_type_variation = &"TitleLabel"
	title_label.text = title
	box.add_child(title_label)
	var message_label := Label.new()
	message_label.text = message
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(message_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	for i in buttons.size():
		var button := Button.new()
		button.text = buttons[i]
		button.custom_minimum_size = Vector2(160, 48)
		if i == 0:
			button.theme_type_variation = &"PrimaryButton"
		button.pressed.connect(_choose.bind(i))
		row.add_child(button)

func _ready() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size
	for button in find_children("*", "Button", true, false):
		button.grab_focus.call_deferred()
		break

func _choose(index: int) -> void:
	chosen.emit(index)
	queue_free()
