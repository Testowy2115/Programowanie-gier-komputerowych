extends CanvasLayer

@onready var play_button: Button = $Root/MenuBox/PlayButton
@onready var quit_button: Button = $Root/MenuBox/QuitButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer

const GAME_SCENE_PATH = "res://scenes/farm/farm.tscn"
const MUSIC_PATHS = [
	"res://assets/game/audio/music/main_menu.ogg",
	"res://assets/game/audio/music/main_menu.wav",
	"res://assets/game/audio/music/main_menu.mp3"
]

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	load_music()

func load_music() -> void:
	for path in MUSIC_PATHS:
		if ResourceLoader.exists(path):
			music_player.stream = load(path)
			music_player.play()
			return

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
