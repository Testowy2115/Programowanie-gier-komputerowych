extends CanvasLayer

var animals = [
		{"name": "Rainbow Bee", "chance": 10000, "color": Color(1.0, 1.0, 1.0, 1.0), "texture": "res://assets/game/animals/rainbowbee.png", "honey_rate": 50},
		{"name": "Alien Bee", "chance": 1000, "color": Color(1.0, 1.0, 1.0, 1.0), "texture": "res://assets/game/animals/alienbee.png", "honey_rate": 20},
		{"name": "King Bee", "chance": 250, "color": Color(1.0, 1.0, 1.0, 1.0), "texture": "res://assets/game/animals/kingbee.png", "honey_rate": 10},
		{"name": "Ninja Bee", "chance": 100, "color": Color(1.0, 1.0, 1.0, 1.0), "texture": "res://assets/game/animals/ninjabee.png", "honey_rate": 5},
		{"name": "Sad Bee", "chance": 20, "color": Color(1.0, 1.0, 1.0, 1.0), "texture": "res://assets/game/animals/sadbee.png", "honey_rate": 2},
		{"name": "Classic Bee", "chance": 1, "color": Color(1.0, 1.0, 1.0, 1.0), "texture": "res://assets/game/animals/classicbee.png", "honey_rate": 1}
]

@onready var roll_button = $UI/BottomBar/RollButton
@onready var result_label = $UI/CenterDisplay/ResultLabel
@onready var chance_label = $UI/CenterDisplay/ChanceLabel
@onready var backpack_button = $UI/BottomBar/BackpackButton

@onready var dim_bg = $UI/DimBackground
@onready var pollen_counter = $UI/PollenCounter
@onready var zone_unlock_label = $UI/ZoneUnlockLabel
@onready var focus_arrows = $UI/FocusArrows
@onready var tutorial_panel = $UI/TutorialPanel
@onready var tutorial_label = $UI/TutorialPanel/TutorialLabel
@onready var tutorial_arrow = $UI/TutorialArrow
@onready var skip_tutorial_button = $UI/TutorialPanel/SkipTutorialButton

@onready var backpack_panel = $BackpackPanel
@onready var close_button = $BackpackPanel/CloseButton
@onready var all_items_container = $BackpackPanel/ScrollContainer/AllItemsContainer
@onready var equipped_container = $BackpackPanel/EquippedContainer
@onready var equip_best_button = $BackpackPanel/EquipBestButton
@onready var equipped_label = $BackpackPanel/EquippedLabel
@onready var upgrade_button = $UI/BottomBar/UpgradeButton
@onready var upgrade_panel = $UpgradePanel
@onready var upgrade_close_button = $UpgradePanel/CloseButton
@onready var buy_luck_button = $UpgradePanel/ScrollContainer/Rows/LuckRow/BuyLuckButton
@onready var buy_equip_slot_button = $UpgradePanel/ScrollContainer/Rows/EquipSlotRow/BuyEquipSlotButton
@onready var luck_level_label = $UpgradePanel/ScrollContainer/Rows/LuckRow/LuckLevelLabel
@onready var luck_cost_label = $UpgradePanel/ScrollContainer/Rows/LuckRow/LuckCostLabel
@onready var equip_slot_level_label = $UpgradePanel/ScrollContainer/Rows/EquipSlotRow/EquipSlotLevelLabel
@onready var equip_slot_cost_label = $UpgradePanel/ScrollContainer/Rows/EquipSlotRow/EquipSlotCostLabel
@onready var buy_pollen_button = $UpgradePanel/ScrollContainer/Rows/PollenRow/BuyPollenButton
@onready var pollen_level_label = $UpgradePanel/ScrollContainer/Rows/PollenRow/PollenLevelLabel
@onready var pollen_cost_label = $UpgradePanel/ScrollContainer/Rows/PollenRow/PollenCostLabel
@onready var pollen_collect_sfx: AudioStreamPlayer = $Sfx/PollenCollect
@onready var zone_unlock_sfx: AudioStreamPlayer = $Sfx/ZoneUnlock
@onready var rolling_sfx: AudioStreamPlayer = $Sfx/Rolling
@onready var click_sfx: AudioStreamPlayer = $Sfx/Click
@onready var equip_sfx: AudioStreamPlayer = $Sfx/Equip

var is_rolling = false
var is_roll_locked = false
var roll_time_left = 0.0
var visual_update_timer = 0.0
var final_result = {}
var roll_fx_tween: Tween = null
var roll_end_tween: Tween = null
var zone_unlock_tween: Tween = null
var last_displayed_pollen: int = 0
var tutorial_step: int = 0
var tutorial_done: bool = false
var tutorial_arrow_tween: Tween = null

const PIXEL_FONT_PATH = "res://assets/game/fonts/04B.TTF"
const POLLEN_COLLECT_SFX_PATHS = [
	"res://assets/game/audio/sfx/pollen_collect.wav",
]
const ZONE_UNLOCK_SFX_PATHS = [
	"res://assets/game/audio/sfx/zone_unlock.wav",
]
const ROLLING_SFX_PATHS = [
	"res://assets/game/audio/sfx/rolling.wav",
]
const CLICK_SFX_PATHS = [
	"res://assets/game/audio/sfx/click.ogg",
]
const EQUIP_SFX_PATHS = [
	"res://assets/game/audio/sfx/equip.mp3",
]
var pixel_font: Font = null

var inventory = {}
var equipped_animals = []
var max_equipped = 5
var current_final_node: Node = null
var luck_level = 0
var max_luck_level = 10
var max_equip_slots = 8
var pollen_multiplier_level = 1
var max_pollen_multiplier = 10

const ROLL_VIEW_SIZE = Vector2(320, 300)
const ROLL_CARD_SIZE = Vector2(300, 140)
const ROLL_ITEM_HEIGHT = 140
const ROLL_ITEM_SEPARATION = 14
const ROLL_TOTAL_ITEMS = 28
const ROLL_SPIN_TIME = 2.8
const TUTORIAL_ROLL = 0
const TUTORIAL_BACKPACK = 1
const TUTORIAL_EQUIP = 2
const TUTORIAL_COLLECT = 3
const TUTORIAL_UPGRADE = 4

func _ready() -> void:
	result_label.text = ""
	chance_label.text = ""
	result_label.hide()
	chance_label.hide()
	$UI/CenterDisplay.move_child(chance_label, 0)
	pixel_font = load(PIXEL_FONT_PATH)
	
	$BackpackPanel.process_mode = Node.PROCESS_MODE_ALWAYS
	backpack_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	roll_button.pressed.connect(_on_roll_button_pressed)
	backpack_button.pressed.connect(_on_backpack_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	equip_best_button.pressed.connect(_on_equip_best_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	upgrade_close_button.pressed.connect(_on_upgrade_close_pressed)
	buy_luck_button.pressed.connect(_on_buy_luck_pressed)
	buy_equip_slot_button.pressed.connect(_on_buy_equip_slot_pressed)
	buy_pollen_button.pressed.connect(_on_buy_pollen_pressed)
	skip_tutorial_button.pressed.connect(_on_skip_tutorial_pressed)
	setup_icon_button_hover(backpack_button)
	setup_icon_button_hover(roll_button)
	setup_icon_button_hover(upgrade_button)
	load_audio_stream(pollen_collect_sfx, POLLEN_COLLECT_SFX_PATHS)
	load_audio_stream(zone_unlock_sfx, ZONE_UNLOCK_SFX_PATHS)
	load_audio_stream(rolling_sfx, ROLLING_SFX_PATHS)
	load_audio_stream(click_sfx, CLICK_SFX_PATHS)
	load_audio_stream(equip_sfx, EQUIP_SFX_PATHS)

	update_backpack_ui()
	update_upgrade_ui()
	start_tutorial()

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null or pollen_counter == null:
		return
	var displayed_pollen = int(player.pollen)
	if pollen_counter.has_method("set_value"):
		pollen_counter.set_value(displayed_pollen, 0)
	if displayed_pollen > last_displayed_pollen:
		play_sfx(pollen_collect_sfx, false)
		if tutorial_step == TUTORIAL_COLLECT:
			set_tutorial_step(TUTORIAL_UPGRADE)
	last_displayed_pollen = displayed_pollen
	if upgrade_panel != null and upgrade_panel.visible:
		update_upgrade_ui()
	update_tutorial_arrow()

func load_audio_stream(player: AudioStreamPlayer, paths: Array) -> void:
	if player == null:
		return
	for path in paths:
		if ResourceLoader.exists(path):
			player.stream = load(path)
			return

func play_sfx(player: AudioStreamPlayer, restart: bool = true) -> void:
	if player == null or player.stream == null:
		return
	if player.playing and not restart:
		return
	if restart:
		player.stop()
	player.play()

func refresh_dim_background() -> void:
	if dim_bg == null:
		return
	var should_show = is_roll_locked or backpack_panel.visible or upgrade_panel.visible
	dim_bg.visible = should_show
	if should_show and dim_bg.color.a < 0.5:
		dim_bg.color = Color(0, 0, 0, 0.5)

func show_zone_unlocked(zone_name: String) -> void:
	if zone_unlock_label == null:
		return
	play_sfx(zone_unlock_sfx)
	if zone_unlock_tween != null and zone_unlock_tween.is_valid():
		zone_unlock_tween.kill()

	zone_unlock_label.text = "NEW ZONE UNLOCKED!\n" + get_zone_display_name(zone_name)
	zone_unlock_label.visible = true
	zone_unlock_label.modulate.a = 0.0
	zone_unlock_label.scale = Vector2(0.9, 0.9)

	zone_unlock_tween = create_tween()
	zone_unlock_tween.set_trans(Tween.TRANS_BACK)
	zone_unlock_tween.set_ease(Tween.EASE_OUT)
	zone_unlock_tween.tween_property(zone_unlock_label, "modulate:a", 1.0, 0.2)
	zone_unlock_tween.parallel().tween_property(zone_unlock_label, "scale", Vector2.ONE, 0.2)
	zone_unlock_tween.tween_interval(1.6)
	zone_unlock_tween.set_trans(Tween.TRANS_QUAD)
	zone_unlock_tween.tween_property(zone_unlock_label, "modulate:a", 0.0, 0.35)
	zone_unlock_tween.tween_callback(func():
		zone_unlock_label.visible = false
	)

func get_zone_display_name(zone_name: String) -> String:
	return zone_name.replace("Arena", " Zone").replace("_", " ").to_upper()

func start_tutorial() -> void:
	tutorial_done = false
	tutorial_panel.visible = true
	tutorial_arrow.visible = true
	set_tutorial_step(TUTORIAL_ROLL)

func set_tutorial_step(step: int) -> void:
	if tutorial_done:
		return
	tutorial_step = step
	if step == TUTORIAL_ROLL:
		tutorial_label.text = "Click ROLL to get your first bee."
	elif step == TUTORIAL_BACKPACK:
		tutorial_label.text = "Open BACKPACK to see your bees."
	elif step == TUTORIAL_EQUIP:
		tutorial_label.text = "Click a bee or EQUIP BEST to equip it."
	elif step == TUTORIAL_COLLECT:
		tutorial_label.text = "Walk near flowers. Equipped bees collect pollen for you."
	elif step == TUTORIAL_UPGRADE:
		tutorial_label.text = "Open UPGRADE and buy stronger progress."
	update_tutorial_arrow()

func finish_tutorial() -> void:
	tutorial_done = true
	tutorial_panel.visible = false
	tutorial_arrow.visible = false
	if tutorial_arrow_tween != null and tutorial_arrow_tween.is_valid():
		tutorial_arrow_tween.kill()

func _on_skip_tutorial_pressed() -> void:
	play_sfx(click_sfx)
	finish_tutorial()

func update_tutorial_arrow() -> void:
	if tutorial_done or tutorial_arrow == null:
		return
	var target = get_tutorial_target()
	if target == null or not is_instance_valid(target):
		tutorial_arrow.visible = false
		return
	tutorial_arrow.visible = true
	var rect = target.get_global_rect()
	var arrow_size = tutorial_arrow.size
	var arrow_offset_x = get_tutorial_arrow_offset_x()
	tutorial_arrow.global_position = Vector2(rect.position.x + rect.size.x * 0.5 - arrow_size.x * 0.5 + arrow_offset_x, rect.position.y - 48.0)
	if tutorial_arrow_tween == null or not tutorial_arrow_tween.is_valid():
		tutorial_arrow_tween = create_tween()
		tutorial_arrow_tween.set_loops()
		tutorial_arrow_tween.set_trans(Tween.TRANS_SINE)
		tutorial_arrow_tween.set_ease(Tween.EASE_IN_OUT)
		tutorial_arrow_tween.tween_property(tutorial_arrow, "scale", Vector2(1.15, 1.15), 0.45)
		tutorial_arrow_tween.tween_property(tutorial_arrow, "scale", Vector2.ONE, 0.45)

func get_tutorial_target() -> Control:
	if tutorial_step == TUTORIAL_ROLL:
		return roll_button
	if tutorial_step == TUTORIAL_BACKPACK:
		return backpack_button
	if tutorial_step == TUTORIAL_EQUIP:
		if backpack_panel.visible:
			if all_items_container.get_child_count() > 0:
				return all_items_container.get_child(0)
			return equip_best_button
		return backpack_button
	if tutorial_step == TUTORIAL_UPGRADE:
		return upgrade_button
	return pollen_counter

func get_tutorial_arrow_offset_x() -> float:
	if tutorial_step == TUTORIAL_BACKPACK or tutorial_step == TUTORIAL_EQUIP:
		return 14.0
	if tutorial_step == TUTORIAL_UPGRADE:
		return -18.0
	return 0.0

func add_to_inventory(animal: Dictionary) -> void:
	var animal_name = animal["name"]
	if inventory.has(animal_name):
		inventory[animal_name] += 1
	else:
		inventory[animal_name] = 1
	update_backpack_ui()

func get_luck_cost() -> int:
	return 100 + luck_level * 75

func get_equip_slot_cost() -> int:
	return 150 + (max_equipped - 5) * 150

func get_pollen_cost() -> int:
	return 250 + (pollen_multiplier_level - 1) * 250

func get_luck_multiplier() -> float:
	return 1.0 + luck_level * 0.12

func apply_pollen_multiplier() -> void:
	var player = get_player()
	if player == null:
		return
	player.pollen_multiplier = float(pollen_multiplier_level)

func get_player() -> Node:
	return get_tree().get_first_node_in_group("player")

func can_player_afford(cost: int) -> bool:
	var player = get_player()
	return player != null and player.pollen >= cost

func spend_player_pollen(cost: int) -> bool:
	var player = get_player()
	if player == null:
		return false
	if player.has_method("spend_pollen"):
		return player.spend_pollen(cost)
	if player.pollen < cost:
		return false
	player.pollen -= cost
	return true

func update_upgrade_ui() -> void:
	if upgrade_panel == null:
		return
	var luck_cost = get_luck_cost()
	var equip_cost = get_equip_slot_cost()
	var pollen_cost = get_pollen_cost()
	luck_level_label.text = "Level " + str(luck_level) + "/" + str(max_luck_level)
	equip_slot_level_label.text = "Slots " + str(max_equipped) + "/" + str(max_equip_slots)
	pollen_level_label.text = "Multiplier x" + str(pollen_multiplier_level)
	luck_cost_label.text = "MAX" if luck_level >= max_luck_level else "Cost " + str(luck_cost)
	equip_slot_cost_label.text = "MAX" if max_equipped >= max_equip_slots else "Cost " + str(equip_cost)
	pollen_cost_label.text = "MAX" if pollen_multiplier_level >= max_pollen_multiplier else "Cost " + str(pollen_cost)
	buy_luck_button.disabled = luck_level >= max_luck_level or not can_player_afford(luck_cost)
	buy_equip_slot_button.disabled = max_equipped >= max_equip_slots or not can_player_afford(equip_cost)
	buy_pollen_button.disabled = pollen_multiplier_level >= max_pollen_multiplier or not can_player_afford(pollen_cost)

func _on_upgrade_button_pressed() -> void:
	play_sfx(click_sfx)
	if tutorial_step == TUTORIAL_UPGRADE:
		finish_tutorial()
	upgrade_panel.visible = not upgrade_panel.visible
	if upgrade_panel.visible:
		backpack_panel.visible = false
		refresh_dim_background()
		focus_arrows.visible = false
		update_upgrade_ui()
	else:
		refresh_dim_background()
		focus_arrows.visible = not is_roll_locked

func _on_upgrade_close_pressed() -> void:
	play_sfx(click_sfx)
	upgrade_panel.visible = false
	refresh_dim_background()
	focus_arrows.visible = not is_roll_locked

func _on_buy_luck_pressed() -> void:
	play_sfx(click_sfx)
	if luck_level >= max_luck_level:
		return
	if not spend_player_pollen(get_luck_cost()):
		return
	luck_level += 1
	update_upgrade_ui()

func _on_buy_equip_slot_pressed() -> void:
	play_sfx(click_sfx)
	if max_equipped >= max_equip_slots:
		return
	if not spend_player_pollen(get_equip_slot_cost()):
		return
	max_equipped += 1
	update_backpack_ui()
	update_upgrade_ui()

func _on_buy_pollen_pressed() -> void:
	play_sfx(click_sfx)
	if pollen_multiplier_level >= max_pollen_multiplier:
		return
	if not spend_player_pollen(get_pollen_cost()):
		return
	pollen_multiplier_level += 1
	apply_pollen_multiplier()
	update_upgrade_ui()

func setup_icon_button_hover(button: Button) -> void:
	if button == null or not button.has_node("Icon"):
		return

	var icon = button.get_node("Icon")
	icon.pivot_offset = icon.size * 0.5
	var caption = button.get_node("Caption") if button.has_node("Caption") else null
	if caption != null:
		caption.pivot_offset = caption.size * 0.5
	button.mouse_entered.connect(func():
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(icon, "scale", Vector2(1.08, 1.08), 0.12)
		if caption != null:
			tween.parallel().tween_property(caption, "scale", Vector2(1.08, 1.08), 0.12)
	)
	button.mouse_exited.connect(func():
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(icon, "scale", Vector2.ONE, 0.12)
		if caption != null:
			tween.parallel().tween_property(caption, "scale", Vector2.ONE, 0.12)
	)

func _on_backpack_button_pressed() -> void:
	play_sfx(click_sfx)
	if tutorial_step == TUTORIAL_BACKPACK:
		set_tutorial_step(TUTORIAL_EQUIP)
	if backpack_panel.visible:
		backpack_panel.visible = false
		refresh_dim_background()
		focus_arrows.visible = not is_roll_locked
	else:
		backpack_panel.visible = true
		upgrade_panel.visible = false
		refresh_dim_background()
		focus_arrows.visible = false
		update_backpack_ui()

func _on_close_button_pressed() -> void:
	play_sfx(click_sfx)
	backpack_panel.visible = false
	refresh_dim_background()
	focus_arrows.visible = not is_roll_locked

func _on_equip_best_pressed() -> void:
	play_sfx(click_sfx)
	equipped_animals.clear()
	var owned = []
	for animal_name in inventory.keys():
		for i in range(inventory[animal_name]):
			owned.append(get_animal_data(animal_name))
			
	owned.sort_custom(func(a, b): return a["chance"] > b["chance"])
	
	for i in range(min(max_equipped, owned.size())):
		equipped_animals.append(owned[i]["name"])
		
	update_backpack_ui()
	update_pet_follow()
	if tutorial_step == TUTORIAL_EQUIP and equipped_animals.size() > 0:
		set_tutorial_step(TUTORIAL_COLLECT)

func update_backpack_ui() -> void:
	for child in all_items_container.get_children():
		child.queue_free()
	for child in equipped_container.get_children():
		child.queue_free()
		
	equipped_label.text = str(equipped_animals.size()) + "/" + str(max_equipped) + " Equipped"
	for animal_name in equipped_animals:
		var animal = get_animal_data(animal_name)
		var item_ui = create_item_card(animal, 1, true)
		if item_ui != null:
			equipped_container.add_child(item_ui)
		
	var sorted_inventory_keys = inventory.keys()
	sorted_inventory_keys.sort_custom(func(a, b): return get_animal_data(a)["chance"] > get_animal_data(b)["chance"])

	for animal_name in sorted_inventory_keys:
		var available_count = inventory[animal_name] - get_equipped_count(animal_name)
		if available_count > 0:
			var animal = get_animal_data(animal_name)
			var item_ui = create_item_card(animal, available_count, false)
			if item_ui != null:
				all_items_container.add_child(item_ui)

func get_animal_data(animal_name: String) -> Dictionary:
	for a in animals:
		if a["name"] == animal_name:
			return a
	return animals[0]

func roll_animal() -> Dictionary:
	var sorted_animals = animals.duplicate()
	sorted_animals.sort_custom(func(a, b): return a["chance"] > b["chance"])
	
	for animal in sorted_animals:
		var effective_chance = max(1, int(float(animal["chance"]) / get_luck_multiplier()))
		if randi() % effective_chance == 0:
			return animal
			
	return animals[animals.size() - 1]

var roll_container: Control = null

func format_chance(chance: int) -> String:
	if chance >= 1000000:
		return str(chance / 1000000.0).pad_decimals(1) + "M"
	elif chance >= 1000:
		return str(chance / 1000.0).pad_decimals(1) + "K"
	return str(chance)

func create_slot_card(animal: Dictionary) -> Control:
	var card = Control.new()
	card.custom_minimum_size = ROLL_CARD_SIZE
	
	var tex = TextureRect.new()
	tex.texture = load(animal["texture"])
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size = Vector2(90, 90)
	tex.position = Vector2(105, 8)
	tex.modulate = animal["color"]
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	card.add_child(tex)
	
	var name_lbl = Label.new()
	name_lbl.text = animal["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.size = Vector2(ROLL_CARD_SIZE.x, 34)
	name_lbl.position = Vector2(0, 106)
	apply_pixel_font(name_lbl, 18)
	name_lbl.add_theme_color_override("font_color", animal["color"])
	name_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	name_lbl.add_theme_constant_override("outline_size", 6)
	card.add_child(name_lbl)
	
	var chance_lbl = Label.new()
	chance_lbl.text = "1/" + format_chance(animal["chance"])
	chance_lbl.rotation_degrees = -15
	chance_lbl.position = Vector2(80, 0)
	apply_pixel_font(chance_lbl, 17)
	chance_lbl.add_theme_color_override("font_color", animal["color"])
	chance_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	chance_lbl.add_theme_constant_override("outline_size", 5)
	card.add_child(chance_lbl)
	
	return card

func create_roll_marker(text: String, pos: Vector2) -> Label:
	var marker = Label.new()
	marker.text = text
	marker.size = Vector2(36, 44)
	marker.position = pos
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_pixel_font(marker, 34)
	marker.add_theme_color_override("font_color", Color(1.0, 0.78, 0.18, 0.95))
	marker.add_theme_color_override("font_outline_color", Color.BLACK)
	marker.add_theme_constant_override("outline_size", 7)
	return marker

func _on_roll_button_pressed() -> void:
	if is_roll_locked:
		return

	play_sfx(click_sfx)
	final_result = roll_animal()
	is_roll_locked = true
	roll_button.disabled = true
	play_sfx(rolling_sfx)
	
	result_label.hide()
	chance_label.hide()
	dim_bg.visible = true
	dim_bg.color = Color(0, 0, 0, 0.5)

	if roll_container != null and is_instance_valid(roll_container):
		roll_container.queue_free()

	var screen_size = get_viewport().get_visible_rect().size
	roll_container = Control.new()
	roll_container.size = ROLL_VIEW_SIZE
	roll_container.position = screen_size * 0.5 - roll_container.size * 0.5
	roll_container.clip_contents = true
	$UI.add_child(roll_container)

	var marker_y = roll_container.position.y + roll_container.size.y * 0.5 - 22
	var marker_center_x = roll_container.position.x + roll_container.size.x * 0.5
	var marker_gap = 72.0
	var left_marker = create_roll_marker(">", Vector2(marker_center_x - marker_gap - 36, marker_y))
	var right_marker = create_roll_marker("<", Vector2(marker_center_x + marker_gap, marker_y))
	$UI.add_child(left_marker)
	$UI.add_child(right_marker)
	
	var reel = VBoxContainer.new()
	reel.add_theme_constant_override("separation", ROLL_ITEM_SEPARATION)
	reel.position = Vector2((roll_container.size.x - ROLL_CARD_SIZE.x) * 0.5, 0)
	roll_container.add_child(reel)
	
	var total_items = ROLL_TOTAL_ITEMS
	var win_index = total_items - 3
	var item_height = ROLL_ITEM_HEIGHT
	var separation = ROLL_ITEM_SEPARATION
	var stride = item_height + separation
	
	for i in range(total_items):
		var anim_data = final_result if i == win_index else get_random_textured_animal()
		var card = create_slot_card(anim_data)
		reel.add_child(card)

	reel.position.y = roll_container.size.y * 0.5 - (item_height * 0.5)
	
	var target_y = roll_container.size.y * 0.5 - (win_index * stride + item_height * 0.5)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(reel, "position:y", target_y, ROLL_SPIN_TIME)
	
	tween.tween_callback(func():
		if rolling_sfx != null:
			rolling_sfx.stop()
		add_to_inventory(final_result)
		if tutorial_step == TUTORIAL_ROLL:
			set_tutorial_step(TUTORIAL_BACKPACK)
		
		var final_card = reel.get_child(win_index)
		final_card.pivot_offset = ROLL_CARD_SIZE * 0.5
		
		var pop_tween = create_tween()
		pop_tween.set_trans(Tween.TRANS_ELASTIC)
		pop_tween.set_ease(Tween.EASE_OUT)
		pop_tween.tween_property(final_card, "scale", Vector2(1.12, 1.12), 0.45)
		
		pop_tween.tween_interval(1.1)
		pop_tween.tween_property(dim_bg, "color", Color(0, 0, 0, 0), 0.5)
		pop_tween.parallel().tween_property(roll_container, "modulate:a", 0.0, 0.5)
		pop_tween.parallel().tween_property(left_marker, "modulate:a", 0.0, 0.5)
		pop_tween.parallel().tween_property(right_marker, "modulate:a", 0.0, 0.5)
		pop_tween.tween_callback(func():
			if is_instance_valid(roll_container):
				roll_container.queue_free()
			if is_instance_valid(left_marker):
				left_marker.queue_free()
			if is_instance_valid(right_marker):
				right_marker.queue_free()
			roll_button.disabled = false
			is_roll_locked = false
			refresh_dim_background()
		)
	)

func get_random_textured_animal() -> Dictionary:
	var texture_animals = []
	for animal in animals:
		if animal["texture"] != null and animal["texture"] != "":
			texture_animals.append(animal)
	if texture_animals.size() == 0:
		return animals[0]
	return texture_animals[randi() % texture_animals.size()]

func get_focus_center_y() -> float:
	var rect = focus_arrows.get_global_rect()
	return rect.position.y + rect.size.y * 0.5

func create_animal_card(animal: Dictionary, size: int, _is_equipped_row: bool = false) -> Control:
	var card = Control.new()
	card.custom_minimum_size = Vector2(size, size)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not _is_equipped_row:
		var panel = Panel.new()
		panel.size = Vector2(size, size)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var box = StyleBoxFlat.new()
		box.bg_color = Color(0.02, 0.025, 0.04, 0.72)
		box.border_width_left = 3
		box.border_width_top = 3
		box.border_width_right = 3
		box.border_width_bottom = 3
		box.border_color = Color(0, 0, 0, 0.95)
		box.corner_radius_top_left = 8
		box.corner_radius_top_right = 8
		box.corner_radius_bottom_left = 8
		box.corner_radius_bottom_right = 8
		panel.add_theme_stylebox_override("panel", box)
		card.add_child(panel)
	
	
	var tex = TextureRect.new()
	tex.texture = load(animal["texture"])
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size = Vector2(size * 0.84, size * 0.72)
	tex.position = Vector2(size * 0.08, size * 0.08)
	tex.modulate = animal["color"]
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(tex)
	
	var chance_lbl = Label.new()
	chance_lbl.text = "1/" + format_chance(animal["chance"])
	chance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chance_lbl.size = Vector2(size, 22)
	chance_lbl.position = Vector2(0, size - 25)
	apply_pixel_font(chance_lbl, 10)
	chance_lbl.add_theme_color_override("font_color", animal["color"])
	chance_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	chance_lbl.add_theme_constant_override("outline_size", 4)
	chance_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(chance_lbl)
	
	return card

func create_item_card(animal: Dictionary, count: int, is_equipped_row: bool = false) -> Control:
	var card_size = 60 if is_equipped_row else 76
	var card = create_animal_card(animal, card_size, is_equipped_row)
	if card == null:
		return null

	var card_button = Button.new()
	card_button.flat = true
	card_button.focus_mode = Control.FOCUS_NONE
	card_button.custom_minimum_size = card.custom_minimum_size
	card_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	card_button.add_child(card)
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.offset_left = 0
	card.offset_top = 0
	card.offset_right = 0
	card.offset_bottom = 0

	if not is_equipped_row:
		var count_label = Label.new()
		apply_pixel_font(count_label, 12)
		count_label.text = "x" + str(count)
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_label.size = Vector2(card_size, 20)
		count_label.position = Vector2(-4, 1)
		count_label.add_theme_color_override("font_color", Color.WHITE)
		count_label.add_theme_color_override("font_outline_color", Color.BLACK)
		count_label.add_theme_constant_override("outline_size", 4)
		card.add_child(count_label)

	var animal_name = animal["name"]
	if is_equipped_row:
		card_button.pressed.connect(func():
			unequip_animal(animal_name)
		)
	else:
		card_button.pressed.connect(func():
			toggle_equip(animal_name)
		)

	return card_button

func get_equipped_count(animal_name: String) -> int:
	var count = 0
	for animal in equipped_animals:
		if animal == animal_name:
			count += 1
	return count

func can_equip_animal(animal_name: String) -> bool:
	var owned = inventory.get(animal_name, 0)
	return equipped_animals.size() < max_equipped and get_equipped_count(animal_name) < owned

func equip_animal(animal_name: String) -> void:
	if not can_equip_animal(animal_name):
		return
	play_sfx(equip_sfx)
	equipped_animals.append(animal_name)
	update_backpack_ui()
	update_pet_follow()
	if tutorial_step == TUTORIAL_EQUIP:
		set_tutorial_step(TUTORIAL_COLLECT)

func unequip_animal(animal_name: String) -> void:
	var idx = equipped_animals.find(animal_name)
	if idx == -1:
		return
	play_sfx(equip_sfx)
	equipped_animals.remove_at(idx)
	update_backpack_ui()
	update_pet_follow()

func toggle_equip(animal_name: String) -> void:
	if can_equip_animal(animal_name):
		equip_animal(animal_name)
	elif get_equipped_count(animal_name) > 0:
		unequip_animal(animal_name)

func update_pet_follow() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var bees_data_array : Array = []
	for animal_name in equipped_animals:
		var animal = get_animal_data(animal_name)
		bees_data_array.append(animal)

	if player.has_method("sync_bees"):
		player.sync_bees(bees_data_array)

func apply_pixel_font(control: Control, size: int) -> void:
	if pixel_font == null:
		return
	control.add_theme_font_override("font", pixel_font)
	control.add_theme_font_size_override("font_size", size)

func apply_pixel_font_recursive(node: Node) -> void:
	if node == pollen_counter:
		return
	if node is Label:
		apply_pixel_font(node, 16)
	elif node is Button:
		apply_pixel_font(node, 18)
	for child in node.get_children():
		apply_pixel_font_recursive(child)
