extends Control

@export var icon_texture: Texture2D = null
@export var fallback_icon_path: String = "res://assets/game/ui/pollen_icon.png"

@onready var icon: TextureRect = $Icon
@onready var value_label: Label = $ValueLabel

func _ready() -> void:
	if icon_texture != null:
		icon.texture = icon_texture
	elif ResourceLoader.exists(fallback_icon_path):
		icon.texture = load(fallback_icon_path)

	set_value(0, 0)

func set_value(current: int, maximum: int) -> void:
	if value_label == null:
		return
	if maximum > 0:
		value_label.text = format_number(current) + "/" + format_number(maximum)
	else:
		value_label.text = format_number(current)

func format_number(value: int) -> String:
	if value >= 1000000000:
		return format_suffix(value, 1000000000, "B")
	if value >= 1000000:
		return format_suffix(value, 1000000, "M")
	if value >= 1000:
		return format_suffix(value, 1000, "K")
	return str(value)

func format_suffix(value: int, divisor: int, suffix: String) -> String:
	var short_value = float(value) / float(divisor)
	if short_value >= 100.0 or int(short_value * 10.0) % 10 == 0:
		return str(int(short_value)) + suffix
	return str(short_value).pad_decimals(1) + suffix
