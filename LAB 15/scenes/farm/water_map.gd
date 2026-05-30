@tool
extends Node2D

@export var water_texture: Texture2D:
	set(value):
		water_texture = value
		rebuild()

@export var play_area_tiles := Vector2i(96, 24):
	set(value):
		play_area_tiles = value
		rebuild()

@export var margin_tiles := Vector2i(8, 6):
	set(value):
		margin_tiles = value
		rebuild()

@export var tile_size := 16:
	set(value):
		tile_size = value
		rebuild()

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	if not is_inside_tree() or water_texture == null:
		return

	for child in get_children():
		child.queue_free()

	var total_tiles = play_area_tiles + margin_tiles * 2
	var offset = Vector2(total_tiles.x * tile_size, total_tiles.y * tile_size) * -0.5

	for y in range(total_tiles.y):
		for x in range(total_tiles.x):
			if is_inside_play_area(x, y):
				continue

			var tile = Sprite2D.new()
			tile.name = "Water_%02d_%02d" % [x, y]
			tile.texture = water_texture
			tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.region_enabled = true
			tile.region_rect = get_region_rect(x, y)
			tile.position = offset + Vector2(x * tile_size + tile_size * 0.5, y * tile_size + tile_size * 0.5)
			tile.z_index = -20
			add_child(tile)
			tile.owner = owner

func is_inside_play_area(x: int, y: int) -> bool:
	return x >= margin_tiles.x and x < margin_tiles.x + play_area_tiles.x and y >= margin_tiles.y and y < margin_tiles.y + play_area_tiles.y

func get_region_rect(x: int, y: int) -> Rect2:
	var atlas_x = abs(x * 17 + y * 31) % 4
	return Rect2(atlas_x * tile_size, 0, tile_size, tile_size)
