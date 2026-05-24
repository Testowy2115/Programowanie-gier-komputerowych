extends Area2D

@export var flower_folder: String = ""
var max_nectar: float = 10.0
var nectar_amount: float = 10.0
@export var respawn_time: float = 8.0
@export var texture_path: String = ""

@onready var shape = CollisionShape2D.new()
var sprite: Sprite2D = null
var respawn_timer: Timer = null

func _ready():
	add_to_group("flowers")
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(32, 32)
	shape.shape = rect_shape
	add_child(shape)
	setup_sprite()
	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.wait_time = respawn_time
	respawn_timer.timeout.connect(_on_respawn_timeout)
	add_child(respawn_timer)

func _process(_delta):
	var scale_factor = max(0.3, nectar_amount / max_nectar)
	scale = Vector2(scale_factor, scale_factor)
	if sprite == null:
		queue_redraw()

func setup_sprite() -> void:
	if texture_path == "":
		texture_path = get_random_flower_texture_path()
	if texture_path == "":
		return

	var texture = load(texture_path)
	if texture == null:
		return

	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	add_child(sprite)

func get_random_flower_texture_path() -> String:
	if flower_folder == "":
		return ""

	var textures = []
	var dir = DirAccess.open(flower_folder)
	if dir == null:
		return ""

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension().to_lower() in ["png", "webp", "jpg", "jpeg"]:
			textures.append(flower_folder + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	if textures.is_empty():
		return ""
	return textures[randi() % textures.size()]

func gather(bee: Node2D, delta: float):
	if nectar_amount <= 0:
		return

	var rate = 2.0
	if "honey_rate" in bee.bee_data:
		rate = float(bee.bee_data["honey_rate"]) / 5.0
	
	var amount = rate * delta
	if amount > nectar_amount:
		amount = nectar_amount
		
	nectar_amount -= amount
	bee.gather_nectar(amount)
	
	if nectar_amount <= 0:
		nectar_amount = 0
		visible = false
		shape.disabled = true
		respawn_timer.start()

func _on_respawn_timeout() -> void:
	nectar_amount = max_nectar
	visible = true
	shape.disabled = false

func _draw():
	if sprite != null:
		return

	draw_line(Vector2(0, 0), Vector2(0, 8), Color(0.2, 0.8, 0.2), 4.0)
	draw_circle(Vector2(-6, -6), 6.0, Color(1.0, 0.4, 0.7))
	draw_circle(Vector2(6, -6), 6.0, Color(1.0, 0.4, 0.7))
	draw_circle(Vector2(-6, 6), 6.0, Color(1.0, 0.4, 0.7))
	draw_circle(Vector2(6, 6), 6.0, Color(1.0, 0.4, 0.7))
	draw_circle(Vector2(0, 0), 6.0, Color(1.0, 0.9, 0.1))
