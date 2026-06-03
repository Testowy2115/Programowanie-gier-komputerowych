extends MeshInstance3D

@export var move_speed: float = 5.0

const LIMIT_X: float = 2.5
const LIMIT_Y: float = 2.0
const PLAYER_BULLET_DIRECTION := Vector3(0, 0, -1)
const ENEMY_BULLET_LAYER := 1 << 3


@export var max_hp := 5
@export var roll_action := "ui_select"
@export var shoot_delay: float = 0.3

var is_invincible := false
var is_roll_active := false

@export var bullet_scene: PackedScene
var _shoot_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("player")
	if has_node("Area3D"):
		$Area3D.body_entered.connect(_on_body_entered)
		$Area3D.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_shooting(delta)
	_handle_roll()

func _handle_movement(delta: float) -> void:
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.y += 1.0
	if Input.is_action_pressed("ui_down"):
		dir.y -= 1.0

	position.x += dir.x * move_speed * delta
	position.y += dir.y * move_speed * delta

	position.x = clamp(position.x, -LIMIT_X, LIMIT_X)
	position.y = clamp(position.y, -LIMIT_Y, LIMIT_Y)

func _handle_shooting(delta: float) -> void:
	_shoot_cooldown -= delta

	if Input.is_action_just_pressed("ui_accept") and _shoot_cooldown <= 0.0:
		shoot()
		_shoot_cooldown = shoot_delay

func _handle_roll() -> void:
	if Input.is_action_just_pressed(roll_action):
		_try_barrel_roll()
		
func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D:
		_take_damage(1)

func _on_area_entered(area: Area3D) -> void:
	_take_damage(1)

	if (int(area.collision_layer) & ENEMY_BULLET_LAYER) != 0:
		var bullet := area.get_parent()
		if bullet != null:
			bullet.queue_free()

func _take_damage(amount: int) -> void:
	if is_invincible:
		return
	GameManager.player_hit(amount)
	
func _try_barrel_roll() -> void:
	if is_roll_active:
		return
	is_roll_active = true
	is_invincible = true
	$AnimationPlayer.play("barrel_roll")
	$AnimationPlayer.animation_finished.connect(_finish_barrel_roll, CONNECT_ONE_SHOT)

func _finish_barrel_roll(_animation_name: StringName) -> void:
	is_invincible = false
	is_roll_active = false
		
func shoot() -> void:
	ProjectileFactory.spawn_bullet(self, bullet_scene, global_position, PLAYER_BULLET_DIRECTION)
