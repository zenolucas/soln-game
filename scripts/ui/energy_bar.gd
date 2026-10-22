extends PanelContainer
## Energy readout: a bar plus "3/5". Pinned to the top-right of the screen
## whatever its host's own position or scale.

@onready var energy_bar: ProgressBar = $Row/Energy
@onready var count_label: Label = $Row/Count
var _shown := -1

func _ready() -> void:
	top_level = true
	energy_bar.max_value = Global.MAX_ENERGY
	_update()
	reset_size()
	position = Vector2(get_viewport_rect().size.x - size.x - 16, 16)

func _process(_delta: float) -> void:
	if Global.user_energy != _shown:
		_update()

func _update() -> void:
	_shown = Global.user_energy
	energy_bar.value = _shown
	count_label.text = "%d/%d" % [_shown, Global.MAX_ENERGY]
	energy_bar.theme_type_variation = &"EnergyBarLow" if _shown <= 1 else &"EnergyBar"
