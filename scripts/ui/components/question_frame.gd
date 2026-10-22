class_name QuestionFrame
extends PanelContainer
## The layout of the teacher portal's in-game preview: the speaker's portrait
## top-left, a speech box with the question beside it, an equation bar below,
## and a footer with feedback and the submit button.
## Built in code so host scenes only need one PanelContainer node with this script.

signal submitted

const LONG_PROMPT := 90
const FEEDBACK_VARIATIONS := {
	"info": &"Feedback",
	"success": &"FeedbackSuccess",
	"warning": &"FeedbackWarning",
	"error": &"FeedbackError",
}

@export var show_portrait := true:
	set(value):
		show_portrait = value
		portrait.visible = value
@export var portrait_texture: Texture2D:
	set(value):
		portrait_texture = value
		portrait_image.texture = value

var portrait := Control.new()
var portrait_image := TextureRect.new()
var speech_box := PanelContainer.new()
var prompt_label := Label.new()
var equation_bar := PanelContainer.new()
var equation_row := HBoxContainer.new()
var feedback_label := Label.new()
var submit_button := Button.new()
var _npc: Node2D

func _init() -> void:
	theme_type_variation = &"QuestionFrame"
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	add_child(layout)

	var top := HBoxContainer.new()
	top.name = "Top"
	top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top.add_theme_constant_override("separation", 16)
	layout.add_child(top)

	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(224, 176)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.resized.connect(_center_npc)
	top.add_child(portrait)
	portrait_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.add_child(portrait_image)

	speech_box.name = "SpeechBox"
	speech_box.theme_type_variation = &"SpeechBox"
	speech_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speech_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top.add_child(speech_box)
	prompt_label.name = "Prompt"
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.custom_minimum_size = Vector2(200, 0)
	speech_box.add_child(prompt_label)

	equation_bar.name = "EquationBar"
	equation_bar.theme_type_variation = &"EquationBar"
	layout.add_child(equation_bar)
	equation_row.name = "EquationRow"
	equation_row.alignment = BoxContainer.ALIGNMENT_CENTER
	equation_row.add_theme_constant_override("separation", 20)
	equation_bar.add_child(equation_row)

	var footer := HBoxContainer.new()
	footer.name = "Footer"
	footer.add_theme_constant_override("separation", 16)
	layout.add_child(footer)
	feedback_label.name = "Feedback"
	feedback_label.theme_type_variation = &"Feedback"
	feedback_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_child(feedback_label)
	submit_button.name = "Submit"
	submit_button.text = "SUBMIT"
	submit_button.theme_type_variation = &"PrimaryButton"
	submit_button.custom_minimum_size = Vector2(160, 48)
	submit_button.pressed.connect(submitted.emit)
	footer.add_child(submit_button)

## Short prompts use the large size; long word problems drop to 16px so they fit.
func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.add_theme_font_size_override("font_size", 24 if text.length() <= LONG_PROMPT else 16)

## kind is "info", "success", "warning" or "error".
func show_feedback(text: String, kind := "info") -> void:
	feedback_label.text = text
	feedback_label.theme_type_variation = FEEDBACK_VARIATIONS.get(kind, &"Feedback")

func add_to_equation(control: Control) -> Control:
	equation_row.add_child(control)
	return control

func add_equation_text(text: String) -> Label:
	var label := Label.new()
	label.theme_type_variation = &"EquationText"
	label.text = text
	equation_row.add_child(label)
	return label

func set_submit_enabled(on: bool) -> void:
	submit_button.disabled = not on

## Moves a host's animated NPC into the portrait slot, scaled by a whole number
## so the pixel art stays crisp. The host keeps driving its animations.
func place_npc(npc: Node2D) -> void:
	_npc = npc
	npc.reparent(portrait, false)
	npc.rotation = 0
	_center_npc()

func _center_npc() -> void:
	if _npc == null:
		return
	var texture := _npc_texture()
	if texture == null:
		return
	# Fit the visible pixels, not the frame's transparent padding.
	var image := texture.get_image()
	var used := image.get_used_rect() if image else Rect2i(Vector2i.ZERO, Vector2i(texture.get_size()))
	if used.size.x <= 0 or used.size.y <= 0:
		used = Rect2i(Vector2i.ZERO, Vector2i(texture.get_size()))
	var fit := floorf(minf(portrait.size.x / used.size.x, portrait.size.y / used.size.y))
	_npc.scale = Vector2.ONE * maxf(fit, 1.0)
	var centered: bool = _npc.get("centered") if _npc.get("centered") != null else true
	var offset: Vector2 = _npc.get("offset") if _npc.get("offset") != null else Vector2.ZERO
	var origin := texture.get_size() / 2 if centered else Vector2.ZERO
	var used_center := Vector2(used.get_center())
	_npc.position = portrait.size / 2 - (used_center - origin + offset) * _npc.scale

func _npc_texture() -> Texture2D:
	if _npc is AnimatedSprite2D and _npc.sprite_frames:
		return _npc.sprite_frames.get_frame_texture(_npc.animation, 0)
	if _npc is Sprite2D and _npc.texture:
		return _npc.texture
	return null
