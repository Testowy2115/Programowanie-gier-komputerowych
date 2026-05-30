extends CharacterBody2D

@export var speed: float = 150.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer

signal pollen_collected(amount: float)

enum PlayerState {
	IDLE,
	WALK
}

var state: PlayerState = PlayerState.IDLE
var current_action: String = "idle"
var current_direction: String = "front"

var bees_data = []
var active_bees = []
var pollen: float = 0.0
var total_pollen_earned: float = 0.0
var pollen_multiplier: float = 1.0
var footstep_timer: float = 0.0
var current_footstep_zone: String = ""

const FOOTSTEP_INTERVAL = 0.32
const FOOTSTEP_PATHS = {
	"GrassArena": [
		"res://assets/game/audio/sfx/footstep.wav",
	],
	"DesertArena": [
		"res://assets/game/audio/sfx/footstep_desert.mp3",
	],
	"WinterArena": [
		"res://assets/game/audio/sfx/footstep_winter.wav",
	]
}

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	var input_direction = get_input_direction()
	update_state(input_direction)
	velocity = input_direction * speed
	move_and_slide()
	update_animation()
	update_footsteps(_delta)

func get_input_direction() -> Vector2:
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		input_direction.y -= 1
	return input_direction.normalized()

func update_state(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
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
		set_state(PlayerState.WALK)
	else:
		set_state(PlayerState.IDLE)

func set_state(new_state: PlayerState) -> void:
	if state == new_state:
		return
	state = new_state
	if state == PlayerState.WALK:
		current_action = "walk"
	else:
		current_action = "idle"

func update_animation() -> void:
	if animated_sprite:
		animated_sprite.play(current_action + "_" + current_direction)

func update_footsteps(delta: float) -> void:
	if state != PlayerState.WALK:
		footstep_timer = FOOTSTEP_INTERVAL
		if footstep_player != null and footstep_player.playing:
			footstep_player.stop()
		return

	update_footstep_stream()
	footstep_timer += delta
	if footstep_timer < FOOTSTEP_INTERVAL:
		return
	footstep_timer = 0.0
	if footstep_player != null and footstep_player.stream != null:
		footstep_player.stop()
		footstep_player.play()

func update_footstep_stream() -> void:
	var zone_name = get_current_zone_name()
	if zone_name == current_footstep_zone:
		return
	current_footstep_zone = zone_name
	var paths = FOOTSTEP_PATHS.get(zone_name, FOOTSTEP_PATHS["GrassArena"])
	for path in paths:
		if ResourceLoader.exists(path):
			footstep_player.stream = load(path)
			return
	footstep_player.stream = null

func get_current_zone_name() -> String:
	var arenas = get_node_or_null("../Arenas")
	if arenas == null:
		return "GrassArena"
	for arena in arenas.get_children():
		var local_pos = arena.to_local(global_position)
		if local_pos.x >= 0.0 and local_pos.x <= 512.0 and local_pos.y >= 0.0 and local_pos.y <= 384.0:
			return arena.name
	return "GrassArena"

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
	var final_amount = amount * pollen_multiplier
	pollen += final_amount
	total_pollen_earned += final_amount
	pollen_collected.emit(final_amount)

func spend_pollen(amount: float) -> bool:
	if pollen < amount:
		return false
	pollen -= amount
	return true
