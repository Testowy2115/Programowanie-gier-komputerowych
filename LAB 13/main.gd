extends Node3D

var bg_music := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(bg_music)
	var stream = preload("res://assets/audio/music.wav")
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	bg_music.stream = stream
	bg_music.volume_db = -10.0
	bg_music.play()
	
	GameManager.game_over.connect(_on_game_over)
	GameManager.level_complete.connect(_on_level_complete)
	
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.hp_changed.connect(_on_hp_changed)
	
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)
	_on_hp_changed(GameManager.player_hp)

func _on_score_changed(new_score: int):
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.text = "Wynik: %d" % new_score

func _on_lives_changed(new_lives: int):
	if has_node("HUD/LivesLabel"):
		$HUD/LivesLabel.text = "Życia: %d" % new_lives

func _on_hp_changed(new_hp: int):
	if has_node("HUD/HPBar"):
		$HUD/HPBar.value = float(new_hp)

func _on_game_over():
	bg_music.stop()
	get_tree().call_deferred("change_scene_to_file", "res://game_over.tscn")

func _on_level_complete():
	bg_music.stop()
	get_tree().call_deferred("change_scene_to_file", "res://level_complete.tscn")
