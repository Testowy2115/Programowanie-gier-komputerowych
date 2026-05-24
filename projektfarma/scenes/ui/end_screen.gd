extends CanvasLayer

@onready var play_again_button: Button = $Root/MenuBox/PlayAgainButton
@onready var menu_button: Button = $Root/MenuBox/MenuButton

const GAME_SCENE_PATH = "res://scenes/farm/farm.tscn"
const MENU_SCENE_PATH = "res://scenes/ui/main_menu.tscn"

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
