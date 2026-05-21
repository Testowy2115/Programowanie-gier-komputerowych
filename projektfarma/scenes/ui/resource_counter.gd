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
	value_label.text = str(current) + "/" + str(maximum)
