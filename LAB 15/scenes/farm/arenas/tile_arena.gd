@tool
extends Node2D

@export var tile_texture: Texture2D:
	set(value):
		tile_texture = value
		rebuild()

@export var arena_tiles := Vector2i(32, 24):
	set(value):
		arena_tiles = value
		rebuild()

@export var tile_size := 16:
	set(value):
		tile_size = value
		rebuild()

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	if not is_inside_tree() or tile_texture == null:
		return

	var tiles_root = get_node_or_null("Tiles")
	if tiles_root == null:
		tiles_root = Node2D.new()
		tiles_root.name = "Tiles"
		add_child(tiles_root)
		tiles_root.owner = owner

	for child in tiles_root.get_children():
		child.queue_free()

	var offset = Vector2(arena_tiles.x * tile_size, arena_tiles.y * tile_size) * -0.5
	for y in range(arena_tiles.y):
		for x in range(arena_tiles.x):
			var tile = Sprite2D.new()
			tile.name = "Tile_%02d_%02d" % [x, y]
			tile.texture = tile_texture
			tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.region_enabled = true
			tile.region_rect = get_region_rect(x, y)
			tile.position = offset + Vector2(x * tile_size + tile_size * 0.5, y * tile_size + tile_size * 0.5)
			tiles_root.add_child(tile)
			tile.owner = owner

func get_region_rect(x: int, y: int) -> Rect2:
	var atlas_x = 1
	var atlas_y = 1

	if x == 0:
		atlas_x = 0
	elif x == arena_tiles.x - 1:
		atlas_x = 2

	if y == 0:
		atlas_y = 0
	elif y == arena_tiles.y - 1:
		atlas_y = 2

	return Rect2(atlas_x * tile_size, atlas_y * tile_size, tile_size, tile_size)
