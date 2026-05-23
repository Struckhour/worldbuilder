extends CanvasLayer

const MAX_HEARTS := 5
const QUARTERS_PER_HEART := 4
const MAX_HEALTH := MAX_HEARTS * QUARTERS_PER_HEART
const HEART_SIZE := Vector2i(16, 16)

const HUD_POS := Vector2(0, 0)
const HUD_PADDING := Vector2(100, 4)
const HEART_SPACING := 16

const HEART_EMPTY_POS := Vector2i(128, 0)
const HEART_QUARTER_POS := Vector2i(112, 0)
const HEART_HALF_POS := Vector2i(96, 0)
const HEART_THREE_QUARTERS_POS := Vector2i(80, 0)
const HEART_FULL_POS := Vector2i(64, 0)

@onready var background: ColorRect = $Background
@onready var game_over_label: Label = $GameOverLabel

var current_health := MAX_HEALTH
var heart_sprites: Array[Sprite2D] = []
var heart_textures: Array[Texture2D] = []

var peace := 100
var peace_label: Label

func _ready() -> void:
	game_over_label.visible = false
	await get_tree().process_frame
	var sheet: Texture2D = preload("res://assets/gfx/objects.png")

	background.position = Vector2.ZERO
	background.size = Vector2(
		get_window().size.x,
		HEART_SIZE.y + HUD_PADDING.y * 2
	)
	background.color = Color(0, 0, 0, 1)

	heart_textures = [
		make_atlas_texture(sheet, HEART_EMPTY_POS),
		make_atlas_texture(sheet, HEART_QUARTER_POS),
		make_atlas_texture(sheet, HEART_HALF_POS),
		make_atlas_texture(sheet, HEART_THREE_QUARTERS_POS),
		make_atlas_texture(sheet, HEART_FULL_POS)
	]

	for i in range(MAX_HEARTS):
		var heart := Sprite2D.new()
		heart.centered = false
		heart.position = HUD_POS + HUD_PADDING + Vector2(i * HEART_SPACING, 0)
		add_child(heart)
		heart_sprites.append(heart)
	peace_label = Label.new()
	peace_label.position = HUD_POS + HUD_PADDING + Vector2(MAX_HEARTS * HEART_SPACING + 8, -2)
	peace_label.text = str(peace)
	peace_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(peace_label)

	update_hearts(current_health)

func set_peace(value: int) -> void:
	peace = clamp(value, 0, 100)
	update_peace_label()

func update_peace_label() -> void:
	if peace_label:
		peace_label.text = str(peace)

func make_atlas_texture(sheet: Texture2D, atlas_pos: Vector2i) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(atlas_pos.x, atlas_pos.y, HEART_SIZE.x, HEART_SIZE.y)
	return atlas

func set_health(value: int) -> void:
	current_health = clamp(value, 0, MAX_HEALTH)
	update_hearts(current_health)

	if current_health <= 0:
		var game_manager = get_tree().current_scene.get_node_or_null("GameManager")
		if game_manager:
			game_manager.trigger_game_over()

func damage(amount: int) -> void:
	set_health(current_health - amount)

func heal(amount: int) -> void:
	set_health(current_health + amount)

func update_hearts(health: int) -> void:
	for i in range(MAX_HEARTS):
		var heart_value: int = clamp(
			health - i * QUARTERS_PER_HEART,
			0,
			QUARTERS_PER_HEART
		)

		heart_sprites[i].texture = heart_textures[heart_value]

func show_game_over() -> void:
	game_over_label.visible = true
