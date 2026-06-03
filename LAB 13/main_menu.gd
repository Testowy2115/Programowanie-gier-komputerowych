extends Control

var bg_music := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(bg_music)
	var stream = preload("res://assets/audio/music.wav")
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	bg_music.stream = stream
	bg_music.volume_db = -10.0
	bg_music.play()
	
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	bg_music.stop()
	GameManager.reset()
	get_tree().change_scene_to_file("res://main.tscn")
