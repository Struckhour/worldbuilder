extends Camera2D

const HUD_HEIGHT := 24

func _ready() -> void:
	var area := GameArea.PLAY_AREA_TILES

	limit_left = area.position.x * GameArea.TILE_SIZE
	limit_top = (
		area.position.y * GameArea.TILE_SIZE
		- HUD_HEIGHT
	)

	limit_right = area.end.x * GameArea.TILE_SIZE
	limit_bottom = area.end.y * GameArea.TILE_SIZE
