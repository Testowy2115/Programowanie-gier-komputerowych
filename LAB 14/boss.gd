extends Node3D

signal died

enum State { IDLE, ATTACK, RETREAT, DEATH }

const PLAYER_BULLET_LAYER := 1 << 2

@export var max_hp: int = 12
@export var score_value: int = 1000
@export var idle_time: float = 2.0
@export var attack_time: float = 4.0
@export var retreat_time: float = 1.5
@export var shoot_interval: float = 0.7
@export var attack_sway_distance: float = 4.0
@export var retreat_distance: float = 8.0
@export var enemy_bullet_scene: PackedScene
@export var explosion_scene: PackedScene

@onready var hitbox_phase_1_shape: CollisionShape3D = $HitboxPhase1/CollisionShape3D
@onready var hitbox_phase_2_shape: CollisionShape3D = $HitboxPhase2/CollisionShape3D

var current_state: State = State.IDLE
var hp: int
var _phase_two_active := false
var _base_position: Vector3
var _state_tween: Tween
var _shoot_timer: Timer
var _state_timer: Timer

func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	_base_position = global_position
	_set_phase_hitboxes(false)
	_connect_hitboxes()
	_create_timers()
	enter_state(State.IDLE)

func enter_state(new_state: State) -> void:
	if current_state == State.DEATH:
		return

	current_state = new_state
	_stop_state_tween()

	match current_state:
		State.IDLE:
			start_idle()
		State.ATTACK:
			start_attack()
		State.RETREAT:
			start_retreat()
		State.DEATH:
			start_death()

func start_idle() -> void:
	_shoot_timer.stop()
	_state_timer.start(idle_time)

func start_attack() -> void:
	_shoot_timer.start(shoot_interval)
	_state_tween = create_tween()
	_state_tween.set_trans(Tween.TRANS_SINE)
	_state_tween.set_ease(Tween.EASE_IN_OUT)
	_state_tween.set_loops()
	_state_tween.tween_property(self, "global_position:x", _base_position.x + attack_sway_distance, attack_time * 0.25)
	_state_tween.tween_property(self, "global_position:x", _base_position.x - attack_sway_distance, attack_time * 0.5)
	_state_tween.tween_property(self, "global_position:x", _base_position.x, attack_time * 0.25)
	_state_timer.start(attack_time)

func start_retreat() -> void:
	_shoot_timer.stop()
	_state_tween = create_tween()
	_state_tween.set_trans(Tween.TRANS_QUAD)
	_state_tween.set_ease(Tween.EASE_IN_OUT)
	_state_tween.tween_property(self, "global_position:z", _base_position.z + retreat_distance, retreat_time)
	_state_tween.tween_property(self, "global_position:z", _base_position.z, retreat_time)
	_state_timer.start(retreat_time * 2.0)

func start_death() -> void:
	_shoot_timer.stop()
	_state_timer.stop()
	_disable_all_hitboxes()
	_spawn_explosion()
	GameManager.add_score(score_value)
	died.emit()
	queue_free()

func take_hit(damage: int) -> void:
	if current_state == State.DEATH:
		return

	hp -= damage
	if hp <= 0:
		enter_state(State.DEATH)
		return

	if not _phase_two_active and hp <= max_hp / 2:
		_phase_two_active = true
		_set_phase_hitboxes(true)

func _connect_hitboxes() -> void:
	$HitboxPhase1.area_entered.connect(func(area: Area3D): _on_hitbox_area_entered(area, 1))
	$HitboxPhase2.area_entered.connect(func(area: Area3D): _on_hitbox_area_entered(area, 2))

func _create_timers() -> void:
	_shoot_timer = Timer.new()
	_shoot_timer.one_shot = false
	add_child(_shoot_timer)
	_shoot_timer.timeout.connect(_shoot_at_player)

	_state_timer = Timer.new()
	_state_timer.one_shot = true
	add_child(_state_timer)
	_state_timer.timeout.connect(_on_state_timer_timeout)

func _on_state_timer_timeout() -> void:
	match current_state:
		State.IDLE:
			enter_state(State.ATTACK)
		State.ATTACK:
			enter_state(State.RETREAT)
		State.RETREAT:
			enter_state(State.ATTACK)

func _shoot_at_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player := players[0] as Node3D
	if player == null:
		return

	var direction := player.global_position - global_position
	ProjectileFactory.spawn_bullet(self, enemy_bullet_scene, global_position, direction, ProjectileFactory.ENEMY_BULLET_LAYER, ProjectileFactory.PLAYER_LAYER_MASK)

func _on_hitbox_area_entered(area: Area3D, damage: int) -> void:
	if (int(area.collision_layer) & PLAYER_BULLET_LAYER) == 0:
		return

	var bullet := area.get_parent()
	if bullet != null:
		bullet.queue_free()
	take_hit(damage)

func _set_phase_hitboxes(phase_two: bool) -> void:
	hitbox_phase_1_shape.disabled = phase_two
	hitbox_phase_2_shape.disabled = not phase_two

func _disable_all_hitboxes() -> void:
	hitbox_phase_1_shape.disabled = true
	hitbox_phase_2_shape.disabled = true

func _stop_state_tween() -> void:
	if _state_tween != null:
		_state_tween.kill()

func _spawn_explosion() -> void:
	if explosion_scene == null:
		return

	var explosion := explosion_scene.instantiate() as Node3D
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
