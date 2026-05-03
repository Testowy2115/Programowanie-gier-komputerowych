extends MeshInstance3D

@export var move_speed: float = 5.0

const limit_x: float = 2.5
const limit_y: float = 2.0

@export var bullet_scene: PackedScene
var _shoot_cooldown: float = 0.0
@export var _shoot_delay: float = 0.3


func _process(delta: float) -> void:
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

	position.x = clamp(position.x, -limit_x, limit_x)
	position.y = clamp(position.y, -limit_y, limit_y)


	_shoot_cooldown -= delta

	if Input.is_action_just_pressed("ui_accept") and _shoot_cooldown <= 0.0:
		shoot()
		_shoot_cooldown = _shoot_delay
		
		
func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position
