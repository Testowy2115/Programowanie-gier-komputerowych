extends Node3D

@export var hp: int = 2
@export var speed: float = 3.0
@export var score_value: int = 100
@export var explosion_scene: PackedScene

@export var sway_amplitude: float = 1.0
@export var sway_period: float = 1.5

@export var shoot_interval: float = 2.5
@export var enemy_bullet_scene: PackedScene

signal died(points: int)

const PLAYER_BULLET_LAYER := 1 << 2

var _start_pos: Vector3
var _shoot_t: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	$Area3D.area_entered.connect(_on_hit)

	_start_pos = global_position
	_start_sway()

func _process(delta: float) -> void:
	_shoot_t += delta
	if _shoot_t >= shoot_interval:
		_shoot_t = 0.0
		_try_shoot()

func _try_shoot() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player := players[0] as Node3D
	if player == null:
		return

	var dir := (player.global_position - global_position)
	ProjectileFactory.spawn_bullet(self, enemy_bullet_scene, global_position, dir, ProjectileFactory.ENEMY_BULLET_LAYER, ProjectileFactory.PLAYER_LAYER_MASK)

func _start_sway() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	tween.tween_property(self, "global_position", _start_pos + Vector3(sway_amplitude, 0, 0), sway_period * 0.5)
	tween.tween_property(self, "global_position", _start_pos + Vector3(-sway_amplitude, 0, 0), sway_period * 0.5)

func _on_hit(area: Area3D) -> void:
	if (int(area.collision_layer) & PLAYER_BULLET_LAYER) == 0:
		return

	var bullet := area.get_parent()
	if bullet != null:
		bullet.queue_free()

	hp -= 1
	if hp <= 0:
		GameManager.add_score(score_value)
		died.emit(score_value)
		_spawn_explosion()
		queue_free()

func _spawn_explosion() -> void:
	if explosion_scene == null:
		return

	var explosion := explosion_scene.instantiate() as Node3D
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
