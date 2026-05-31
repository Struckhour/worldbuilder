extends Node

const TILE_SIZE := 16

const PLAY_AREA_TILES := Rect2i(
	Vector2i(0, -0),
	Vector2i(100, 100)
)

func width_tiles() -> int:
	return PLAY_AREA_TILES.size.x

func height_tiles() -> int:
	return PLAY_AREA_TILES.size.y

func contains_tile(cell: Vector2i) -> bool:
	return PLAY_AREA_TILES.has_point(cell)

func random_tile() -> Vector2i:
	return Vector2i(
		randi_range(PLAY_AREA_TILES.position.x, PLAY_AREA_TILES.end.x - 1),
		randi_range(PLAY_AREA_TILES.position.y, PLAY_AREA_TILES.end.y - 1)
	)

func random_world_position() -> Vector2:
	var cell := random_tile()
	return Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE)

func tile_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE)
