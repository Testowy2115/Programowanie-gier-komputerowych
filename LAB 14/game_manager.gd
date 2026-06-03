extends Node

var score: int = 0
var lives: int = 3
var player_max_hp: int = 5
var player_hp: int = 5

var best_score: int = 0
var is_game_finished: bool = false

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal hp_changed(new_hp: int)
signal game_over
signal level_complete

signal enemy_killed
signal player_damaged

var _sfx_score := AudioStreamPlayer.new()
var _sfx_hit := AudioStreamPlayer.new()
var _sfx_game_over := AudioStreamPlayer.new()

func _ready():
		add_child(_sfx_score)
		add_child(_sfx_hit)
		add_child(_sfx_game_over)

		_sfx_score.stream = preload("res://assets/audio/score.wav")
		_sfx_hit.stream = preload("res://assets/audio/hit.wav")
		_sfx_game_over.stream = preload("res://assets/audio/game_over.wav")

		enemy_killed.connect(func(): _sfx_score.play())
		player_damaged.connect(func(): _sfx_hit.play())
		game_over.connect(func(): _sfx_game_over.play())

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	enemy_killed.emit()

func player_hit(damage: int = 1) -> void:
	if is_game_finished:
		return

	player_hp -= damage
	hp_changed.emit(player_hp)
	player_damaged.emit()
	
	if player_hp <= 0:
		lives -= 1
		lives_changed.emit(lives)
		
		if lives <= 0:
			if score > best_score:
				best_score = score
			is_game_finished = true
			game_over.emit()
		else:
			player_hp = player_max_hp
			hp_changed.emit(player_hp)

func complete_level() -> void:
	if is_game_finished:
		return

	if score > best_score:
		best_score = score
	is_game_finished = true
	level_complete.emit()

func reset() -> void:
	score = 0
	lives = 3
	player_hp = player_max_hp
	is_game_finished = false
	score_changed.emit(score)
	lives_changed.emit(lives)
	hp_changed.emit(player_hp)
