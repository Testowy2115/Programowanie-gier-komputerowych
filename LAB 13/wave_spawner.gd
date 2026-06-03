extends Node

@export var enemy_scene: PackedScene
@export var path_follow: PathFollow3D

var waves: Array[Dictionary] = [
	{ "x_positions": [-3.0, 0.0, 3.0], "z_offset": -30.0, "delay": 2.0 },
	
	{ "x_positions": [-6.0, -3.0, 0.0, 3.0, 6.0], "z_offset": -30.0, "delay": 6.0 },
	
	{ "x_positions": [-8.0, -4.0, -1.0, 1.0, 4.0, 8.0], "z_offset": -35.0, "delay": 11.0 }
]

var _time := 0.0
var _spawned: Array[bool] = []
var _level_completed := false

func _ready() -> void:
	_time = 0.0
	_spawned.resize(waves.size())
	_spawned.fill(false)

func _process(delta: float) -> void:
	if enemy_scene == null or path_follow == null:
		return

	_time += delta

	for i in range(waves.size()):
		var wave: Dictionary = waves[i]
		var delay := float(wave.get("delay", 0.0))
		
		if not _spawned[i] and _time >= delay:
			_spawn_wave(wave)
			_spawned[i] = true

	if not _level_completed and _all_waves_spawned() and get_tree().get_nodes_in_group("enemy").is_empty():
		_level_completed = true
		GameManager.complete_level()

func _spawn_wave(wave: Dictionary) -> void:
	var xs: Array = wave.get("x_positions", [])
	var z_offset := float(wave.get("z_offset", -30.0))
	var base_pos: Vector3 = path_follow.global_position

	for x in xs:
		var enemy := enemy_scene.instantiate() as Node3D
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = base_pos + Vector3(float(x), 0.0, z_offset)

func _all_waves_spawned() -> bool:
	for spawned in _spawned:
		if not spawned:
			return false
	return true
