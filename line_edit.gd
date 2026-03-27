extends LineEdit

func _ready() -> void:
	visible = false

func _on_text_submitted(new_text: String) -> void:
	print(new_text)
