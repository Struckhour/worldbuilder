extends Camera2D

const HUD_HEIGHT := 24
const CAMERA_PADDING_TILES := 20

func _ready() -> void:
	var area := GameArea.PLAY_AREA_TILES
	var pad := CAMERA_PADDING_TILES * GameArea.TILE_SIZE
	limit_left = area.position.x * GameArea.TILE_SIZE - pad
	limit_top = (
		area.position.y * GameArea.TILE_SIZE
		- HUD_HEIGHT - pad
	)

	limit_right = area.end.x * GameArea.TILE_SIZE - pad
	limit_bottom = area.end.y * GameArea.TILE_SIZE - pad
