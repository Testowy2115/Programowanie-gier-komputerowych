extends Node3D

const MUSIC_VOLUME_DB := -10.0
const GAME_OVER_SCENE := "res://game_over.tscn"
const LEVEL_COMPLETE_SCENE := "res://level_complete.tscn"

var bg_music := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(bg_music)
	var stream = preload("res://assets/audio/music.wav")
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	bg_music.stream = stream
	bg_music.volume_db = MUSIC_VOLUME_DB
	bg_music.play()
	
	GameManager.game_over.connect(_on_game_over)
	GameManager.level_complete.connect(_on_level_complete)
	
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.hp_changed.connect(_on_hp_changed)
	
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)
	_on_hp_changed(GameManager.player_hp)
	_connect_boss()

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
	get_tree().call_deferred("change_scene_to_file", GAME_OVER_SCENE)

func _on_level_complete():
	bg_music.stop()
	get_tree().call_deferred("change_scene_to_file", LEVEL_COMPLETE_SCENE)

func _connect_boss() -> void:
	var boss := get_node_or_null("Boss")
	if boss != null and boss.has_signal("died"):
		boss.connect("died", Callable(GameManager, "complete_level"))
