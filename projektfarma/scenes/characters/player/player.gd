extends CharacterBody2D

@export var speed: float = 150.0

@onready var animated_sprite = $AnimatedSprite2D

var current_action: String = "idle"
var current_direction: String = "front"

var bees_data = []
var active_bees = []
var pollen: float = 0.0
var max_pollen: float = 500.0

func _ready() -> void:
	add_to_group("player")

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

func sync_bees(new_bees_data: Array) -> void:
	var bee_script = load("res://scenes/farm/bee.gd")
	if bee_script == null:
		return

	while active_bees.size() > new_bees_data.size():
		var removed_bee = active_bees.pop_back()
		if is_instance_valid(removed_bee):
			removed_bee.queue_free()

	for i in range(new_bees_data.size()):
		var b_data = new_bees_data[i]
		if i < active_bees.size() and is_instance_valid(active_bees[i]):
			active_bees[i].bee_data = b_data
			active_bees[i].update_from_data()
		else:
			var bee_node = Node2D.new()
			bee_node.set_script(bee_script)
			bee_node.bee_data = b_data
			bee_node.player = self
			bee_node.position = self.position
			get_parent().add_child(bee_node)
			active_bees.append(bee_node)

	bees_data = new_bees_data.duplicate()

func add_pollen(amount: float) -> void:
	if pollen < max_pollen:
		pollen += amount
		if pollen > max_pollen:
			pollen = max_pollen
