extends CheckButton
## Shows or hides the Password field next to it.

@onready var password_line_edit: LineEdit = get_parent().get_node("Password")

func _on_toggled(shown: bool) -> void:
	password_line_edit.secret = not shown
