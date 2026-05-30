extends Node2D

var arena_unlock_states = {}
var game_finished = false
@onready var arenas_container = $GameMap/Arenas
@onready var background_music = $BackgroundMusic

const END_SCREEN_PATH = "res://scenes/ui/end_screen.tscn"

func _ready() -> void:
	if background_music != null:
		background_music.finished.connect(_on_background_music_finished)
		if not background_music.playing:
			background_music.play()
	update_arena_locks()

func _process(_delta: float) -> void:
	update_arena_locks()

func update_arena_locks() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var arenas = arenas_container.get_children()
	var unlocked_states = []
	for arena in arenas:
		var unlock_pollen = int(arena.get_meta("unlock_pollen", 0))
		var earned_pollen = player.get("total_pollen_earned")
		if earned_pollen == null:
			earned_pollen = player.pollen
		unlocked_states.append(earned_pollen >= unlock_pollen)

	for i in range(arenas.size()):
		var arena = arenas[i]
		var unlocked = unlocked_states[i]
		var was_unlocked = arena_unlock_states.get(arena.name, unlocked)
		arena.visible = true
		arena.modulate = Color.WHITE if unlocked else Color(0.25, 0.25, 0.25, 0.45)
		set_arena_border_enabled(arena, "Top", unlocked)
		set_arena_border_enabled(arena, "Bottom", unlocked)
		set_arena_border_enabled(arena, "Left", unlocked and (i == 0 or not unlocked_states[i - 1]))
		set_arena_border_enabled(arena, "Right", unlocked and (i == arenas.size() - 1 or not unlocked_states[i + 1]))
		if unlocked and not was_unlocked:
			show_zone_unlocked(arena.name)
			if i == arenas.size() - 1:
				finish_game()
		arena_unlock_states[arena.name] = unlocked

func set_arena_border_enabled(arena: Node, border_name: String, enabled: bool) -> void:
	var border = arena.get_node_or_null("Borders/" + border_name)
	if border == null:
		return
	for child in border.get_children():
		if child is CollisionShape2D:
			child.disabled = not enabled

func show_zone_unlocked(zone_name: String) -> void:
	var farm_ui = get_node_or_null("FarmUI")
	if farm_ui != null and farm_ui.has_method("show_zone_unlocked"):
		farm_ui.show_zone_unlocked(zone_name)

func finish_game() -> void:
	if game_finished:
		return
	game_finished = true
	await get_tree().create_timer(2.4).timeout
	get_tree().change_scene_to_file(END_SCREEN_PATH)

func _on_background_music_finished() -> void:
	if background_music != null and not game_finished:
		background_music.play()
