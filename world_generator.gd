extends Node2D

@onready var ground: TileMapLayer = $"../GroundLayer"
@onready var decorations: TileMapLayer = $"../DecorationLayer"
@onready var fence: TileMapLayer = $"../FenceLayer"

const SOURCE_ID := 0

const FIELD_WIDTH := 50
const FIELD_HEIGHT := 30

const GRASS_TILES := [
	Vector2i(0, 0),
	Vector2i(5, 9),
	Vector2i(5, 10),
	Vector2i(7, 9),
	Vector2i(8, 9),
	Vector2i(7, 10),
	Vector2i(8, 10)

]

const FLOWER_TILES := [
	Vector2i(0, 8),
	Vector2i(1, 8),
	Vector2i(3, 11),
	Vector2i(2, 12),
	Vector2i(3, 12)
]

const FLOWER_CHANCE := 0.06

const FENCE_L_END := Vector2i(0, 19)
const FENCE_R_END := Vector2i(1, 19)
const FENCE_T_END := Vector2i(0, 17)
const FENCE_B_END := Vector2i(0, 18)

const FENCE_H := Vector2i(4, 17)
const FENCE_V := Vector2i(4, 18)

const FENCE_TL := Vector2i(2, 17)
const FENCE_TR := Vector2i(3, 17)
const FENCE_BL := Vector2i(2, 18)
const FENCE_BR := Vector2i(3, 18)

const MAZE_WIDTH := 31
const MAZE_HEIGHT := 21
const MAZE_OFFSET := Vector2i(8, 0)

var maze := []


#func _ready():
	#randomize()
	#build_field()
	#generate_maze()
	#draw_maze()


func build_field() -> void:
	ground.clear()
	decorations.clear()

	for y in range(FIELD_HEIGHT):
		for x in range(FIELD_WIDTH):
			var cell := Vector2i(x, y)
			var grass_tile: Vector2i = GRASS_TILES.pick_random()

			ground.set_cell(cell, SOURCE_ID, grass_tile)

			if randf() < FLOWER_CHANCE:
				var flower_tile: Vector2i = FLOWER_TILES.pick_random()
				decorations.set_cell(cell, SOURCE_ID, flower_tile)


func generate_maze() -> void:
	maze.clear()

	for y in range(MAZE_HEIGHT):
		var row := []
		for x in range(MAZE_WIDTH):
			row.append(1)
		maze.append(row)

	carve_from(Vector2i(1, 1))

	maze[1][0] = 0
	maze[1][1] = 0

	maze[MAZE_HEIGHT - 2][MAZE_WIDTH - 1] = 0
	maze[MAZE_HEIGHT - 2][MAZE_WIDTH - 2] = 0


func carve_from(cell: Vector2i) -> void:
	maze[cell.y][cell.x] = 0

	var directions: Array[Vector2i] = [
		Vector2i(2, 0),
		Vector2i(-2, 0),
		Vector2i(0, 2),
		Vector2i(0, -2)
	]

	directions.shuffle()

	for dir: Vector2i in directions:
		var next_cell: Vector2i = cell + dir

		if next_cell.x <= 0 or next_cell.x >= MAZE_WIDTH - 1:
			continue
		if next_cell.y <= 0 or next_cell.y >= MAZE_HEIGHT - 1:
			continue

		if maze[next_cell.y][next_cell.x] == 1:
			var between: Vector2i = cell + Vector2i(dir.x / 2, dir.y / 2)
			maze[between.y][between.x] = 0
			carve_from(next_cell)


func draw_maze() -> void:
	fence.clear()

	for y in range(MAZE_HEIGHT):
		for x in range(MAZE_WIDTH):
			if maze[y][x] == 1:
				draw_fence_tile(Vector2i(x, y) + MAZE_OFFSET)


func draw_fence_tile(cell: Vector2i) -> void:
	var local_cell := cell - MAZE_OFFSET
	var x := local_cell.x
	var y := local_cell.y

	var up := is_wall(x, y - 1)
	var down := is_wall(x, y + 1)
	var left := is_wall(x - 1, y)
	var right := is_wall(x + 1, y)

	var tile := FENCE_H

	if left and right and not up and not down:
		tile = FENCE_H
	elif up and down and not left and not right:
		tile = FENCE_V
	elif right and down:
		tile = FENCE_TL
	elif left and down:
		tile = FENCE_TR
	elif right and up:
		tile = FENCE_BL
	elif left and up:
		tile = FENCE_BR
	elif right:
		tile = FENCE_L_END
	elif left:
		tile = FENCE_R_END
	elif down:
		tile = FENCE_T_END
	elif up:
		tile = FENCE_B_END

	set_fence(cell, tile)


func is_wall(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= MAZE_WIDTH or y >= MAZE_HEIGHT:
		return false

	return maze[y][x] == 1


func set_fence(cell: Vector2i, atlas_coords: Vector2i) -> void:
	fence.set_cell(cell, SOURCE_ID, atlas_coords)
