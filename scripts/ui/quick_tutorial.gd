extends Control
## A tutorial card over a dimmed screen. The four "filter" rects dim everything
## except one spotlight; "stopper" blocks clicks inside the spotlight.
## Hosts may hand-place the spotlight and card in the scene, or set `target`
## and the spotlight and card are fitted around that control when shown.

@export var next:Control
## Control to spotlight. When set, the filter and card are laid out around it.
var target: Control

const GAP := 16.0
const CARD_SIZE := Vector2(400, 208)

@onready var close_button: Button = $Close/CloseButton
# Whatever had focus before the tutorial took it; handed back when the tutorial closes.
var _previous_focus: Control

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		_on_visibility_changed.call_deferred()

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		var next_shown := next != null and next.visible
		if not next_shown and is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
			_previous_focus.grab_focus.call_deferred()
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused and not is_ancestor_of(focused):
		_previous_focus = focused
	if target:
		_fit_to_target.call_deferred()
	close_button.grab_focus.call_deferred()

func _on_close_button_pressed() -> void:
	if next != null:
		next._previous_focus = _previous_focus
		next.visible = true
	visible = false

func _fit_to_target() -> void:
	var screen := get_viewport_rect()
	var hole := target.get_global_rect().grow(8).intersection(screen)
	_place($filter/left, Rect2(0, 0, hole.position.x, screen.size.y))
	_place($filter/right, Rect2(hole.end.x, 0, screen.size.x - hole.end.x, screen.size.y))
	_place($filter/top, Rect2(hole.position.x, 0, hole.size.x, hole.position.y))
	_place($filter/bottom, Rect2(hole.position.x, hole.end.y, hole.size.x, screen.size.y - hole.end.y))
	_place($filter/stopper, hole)
	# Put the card and its button beside the spotlight: right, left, below or
	# above, whichever fits first; otherwise wherever there is most room.
	var close_size := Vector2(160, 48)
	var needed := CARD_SIZE + Vector2(0, GAP + close_size.y) + Vector2.ONE * GAP * 2
	var areas := [
		Rect2(hole.end.x, 0, screen.size.x - hole.end.x, screen.size.y),
		Rect2(0, 0, hole.position.x, screen.size.y),
		Rect2(0, hole.end.y, screen.size.x, screen.size.y - hole.end.y),
		Rect2(0, 0, screen.size.x, hole.position.y),
	]
	var best: Rect2 = areas[0]
	for area in areas:
		if area.size.x >= needed.x and area.size.y >= needed.y:
			best = area
			break
		if area.get_area() > best.get_area():
			best = area
	var room := best.grow(-GAP)
	var card_size := Vector2(minf(CARD_SIZE.x, room.size.x), minf(CARD_SIZE.y, room.size.y - close_size.y - GAP))
	# Keep the card level with the spotlight where the room allows.
	var stack_height := card_size.y + GAP + close_size.y
	var card_pos := Vector2(room.get_center().x - card_size.x / 2,
		clampf(hole.get_center().y - stack_height / 2, room.position.y, room.end.y - stack_height))
	_place($Close, Rect2(card_pos + Vector2(card_size.x - close_size.x, card_size.y + GAP), close_size))
	# A wrapped label reports its height for its old width; size the card again
	# once it has been laid out at the new width.
	_place($Content, Rect2(card_pos, card_size))
	await get_tree().process_frame
	_place($Content, Rect2(card_pos, card_size))

func _place(control: Control, rect: Rect2) -> void:
	control.visible = rect.size.x > 0 and rect.size.y > 0
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	var scale_factor := control.get_global_transform().get_scale()
	control.global_position = rect.position
	control.size = rect.size / scale_factor
