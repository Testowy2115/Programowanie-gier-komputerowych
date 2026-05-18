extends CharacterBody2D

@export var speed: float = 150.0

@onready var animated_sprite = $AnimatedSprite2D

var current_action: String = "idle"
var current_direction: String = "front"

func _physics_process(_delta: float) -> void:
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		input_direction.y -= 1
		
	input_direction = input_direction.normalized()
	
	velocity = input_direction * speed
	move_and_slide()

	
	update_animation(input_direction)

func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		current_action = "walk"
		
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				current_direction = "right"
			else:
				current_direction = "left"
		else:
			if direction.y > 0:
				current_direction = "front"
			else:
				current_direction = "back"
	else:
		current_action = "idle"
		
	if animated_sprite:
		animated_sprite.play(current_action + "_" + current_direction)
