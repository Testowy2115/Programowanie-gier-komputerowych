@tool
extends Node2D

@export var tall_texture: Texture2D:
	set(value):
		tall_texture = value
		rebuild()

@export var short_texture: Texture2D:
	set(value):
		short_texture = value
		rebuild()

@export var area_size := Vector2(480, 352):
	set(value):
		area_size = value
		rebuild()

@export var spacing := 32:
	set(value):
		spacing = value
		rebuild()

@export var seed := 42:
	set(value):
		seed = value
		rebuild()

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	if not is_inside_tree() or tall_texture == null or short_texture == null:
		return

	for child in get_children():
		child.queue_free()

	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	var columns = int(area_size.x / spacing)
	var rows = int(area_size.y / spacing)
	var start = area_size * -0.5 + Vector2(spacing * 0.5, spacing * 0.5)

	for y in range(rows):
		for x in range(columns):
			if rng.randf() > 0.72:
				continue

			var sprite = Sprite2D.new()
			sprite.texture = tall_texture if rng.randf() > 0.55 else short_texture
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position = start + Vector2(x * spacing, y * spacing) + Vector2(rng.randf_range(-7, 7), rng.randf_range(-7, 7))
			sprite.rotation_degrees = rng.randf_range(-4, 4)
			sprite.z_index = 0
			add_child(sprite)
			sprite.owner = owner
