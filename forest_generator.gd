extends Node2D

@onready var ground: TileMapLayer = $"../GroundLayer"
@onready var decorations: TileMapLayer = $"../DecorationLayer"
@onready var forest_layer: TileMapLayer = $"../FenceLayer"

const SOURCE_ID := 0

const WORLD_WIDTH := 70
const WORLD_HEIGHT := 45

const FLOWER_CHANCE := 0.05
const FOREST_ZONE_MEADOW := 0
const FOREST_ZONE_DENSE := 1
const FOREST_ZONE_PEPPER := 2
const GRASS := {
	"plain": Vector2i(0, 0),
	"alt_1": Vector2i(5, 9),
	"alt_2": Vector2i(5, 10),

	"flower_1": Vector2i(0, 8),
	"flower_2": Vector2i(1, 8),
	"flower_3": Vector2i(3, 11),
	"flower_4": Vector2i(2, 12),
	"flower_5": Vector2i(3, 12),
}

const FOREST := {
	"fill_1": Vector2i(2, 16),

	"edge_top": Vector2i(5, 18),
	"edge_bottom": Vector2i(5, 19),
	"edge_left": Vector2i(6, 18),
	"edge_right": Vector2i(7, 18),

	"corner_top_left": Vector2i(5, 16),
	"corner_top_right": Vector2i(6, 16),
	"corner_bottom_left": Vector2i(5, 17),
	"corner_bottom_right": Vector2i(6, 17),

	"inner_corner_top_left": Vector2i(3, 16),
	"inner_corner_top_right": Vector2i(4, 16),
	"inner_corner_bottom_left": Vector2i(3, 19),
	"inner_corner_bottom_right": Vector2i(4, 19),

	"diagonal_bottom_left_to_top_right": Vector2i(7, 16),
	"diagonal_bottom_right_to_top_left": Vector2i(7, 17),
}

var forest_grid := []


func _ready() -> void:
	randomize()
	build_grass()
	build_flowers()
	build_forest_grid()
	draw_forest()


func build_grass() -> void:
	ground.clear()

	var grass_tiles := [
		GRASS["plain"],
		GRASS["alt_1"],
		GRASS["alt_2"]
	]

	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			var cell := Vector2i(x, y)
			ground.set_cell(cell, SOURCE_ID, grass_tiles.pick_random())


func build_flowers() -> void:
	decorations.clear()

	var flower_tiles := [
		GRASS["flower_1"],
		GRASS["flower_2"],
		GRASS["flower_3"],
		GRASS["flower_4"],
		GRASS["flower_5"]
	]

	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			if randf() < FLOWER_CHANCE:
				var cell := Vector2i(x, y)
				decorations.set_cell(cell, SOURCE_ID, flower_tiles.pick_random())

func remove_single_tile_juts() -> void:
	var copy := []

	for y in range(WORLD_HEIGHT):
		var row := []
		for x in range(WORLD_WIDTH):
			row.append(forest_grid[y][x])
		copy.append(row)

	for y in range(1, WORLD_HEIGHT - 1):
		for x in range(1, WORLD_WIDTH - 1):
			if not copy[y][x]:
				continue

			var up : bool = copy[y - 1][x]
			var down : bool = copy[y + 1][x]
			var left : bool = copy[y][x - 1]
			var right : bool = copy[y][x + 1]

			var neighbor_count := 0
			if up: neighbor_count += 1
			if down: neighbor_count += 1
			if left: neighbor_count += 1
			if right: neighbor_count += 1

			# Removes isolated single-tile nubs / spikes
			if neighbor_count <= 1:
				forest_grid[y][x] = false

func fill_one_tile_gaps() -> void:
	var copy := []

	for y in range(WORLD_HEIGHT):
		var row := []
		for x in range(WORLD_WIDTH):
			row.append(forest_grid[y][x])
		copy.append(row)

	for y in range(1, WORLD_HEIGHT - 1):
		for x in range(1, WORLD_WIDTH - 1):
			if copy[y][x]:
				continue

			var up: bool = copy[y - 1][x]
			var down: bool = copy[y + 1][x]
			var left: bool = copy[y][x - 1]
			var right: bool = copy[y][x + 1]

			# Fill grass cells squeezed between forest horizontally or vertically
			if left and right:
				forest_grid[y][x] = true
			elif up and down:
				forest_grid[y][x] = true

func build_forest_regions(area: Rect2i, target_count: int) -> Array:
	var regions: Array = [area]

	while regions.size() < target_count:
		var index := randi_range(0, regions.size() - 1)
		var rect: Rect2i = regions[index]

		var can_split_vertical := rect.size.x >= 18
		var can_split_horizontal := rect.size.y >= 14

		if not can_split_vertical and not can_split_horizontal:
			break

		regions.remove_at(index)

		var split_vertical := false

		if can_split_vertical and can_split_horizontal:
			split_vertical = randf() < 0.5
		elif can_split_vertical:
			split_vertical = true
		else:
			split_vertical = false

		if split_vertical:
			var split_x := randi_range(7, rect.size.x - 7)

			var left_rect := Rect2i(
				rect.position,
				Vector2i(split_x, rect.size.y)
			)

			var right_rect := Rect2i(
				Vector2i(rect.position.x + split_x, rect.position.y),
				Vector2i(rect.size.x - split_x, rect.size.y)
			)

			regions.append(left_rect)
			regions.append(right_rect)
		else:
			var split_y := randi_range(6, rect.size.y - 6)

			var top_rect := Rect2i(
				rect.position,
				Vector2i(rect.size.x, split_y)
			)

			var bottom_rect := Rect2i(
				Vector2i(rect.position.x, rect.position.y + split_y),
				Vector2i(rect.size.x, rect.size.y - split_y)
			)

			regions.append(top_rect)
			regions.append(bottom_rect)

	return regions

#func build_forest_grid() -> void:
	#forest_grid.clear()
#
	#for y in range(WORLD_HEIGHT):
		#var row := []
		#for x in range(WORLD_WIDTH):
			#row.append(false)
		#forest_grid.append(row)
#
	#add_forest_rect(0, 0, WORLD_WIDTH - 1, 3)
	#add_forest_rect(0, WORLD_HEIGHT - 4, WORLD_WIDTH - 1, WORLD_HEIGHT - 1)
	#add_forest_rect(0, 0, 3, WORLD_HEIGHT - 1)
	#add_forest_rect(WORLD_WIDTH - 4, 0, WORLD_WIDTH - 1, WORLD_HEIGHT - 1)
#
	#add_forest_blob(Vector2i(16, 12), 6, 3)
	#add_forest_blob(Vector2i(48, 11), 4, 5)
	#add_forest_blob(Vector2i(32, 22), 4, 12)
	#add_forest_blob(Vector2i(52, 32), 3, 6)
	#add_forest_blob(Vector2i(12, 35), 7, 4)
#
	#clear_forest_rect(5, 5, 14, 9)
	#clear_forest_rect(28, 0, 36, 8)
	#clear_forest_rect(32, 18, 42, 26)
	#clear_forest_rect(8, 37, 20, 44)
#
	#remove_single_tile_juts()
	#remove_single_tile_juts()
#
	#fill_one_tile_gaps()
	#fill_one_tile_gaps()

func fill_diagonal_bites() -> void:
	var copy := []

	for y in range(WORLD_HEIGHT):
		var row := []
		for x in range(WORLD_WIDTH):
			row.append(forest_grid[y][x])
		copy.append(row)

	for y in range(1, WORLD_HEIGHT - 1):
		for x in range(1, WORLD_WIDTH - 1):
			if copy[y][x]:
				continue

			var up: bool = copy[y - 1][x]
			var down: bool = copy[y + 1][x]
			var left: bool = copy[y][x - 1]
			var right: bool = copy[y][x + 1]

			var up_left: bool = copy[y - 1][x - 1]
			var up_right: bool = copy[y - 1][x + 1]
			var down_left: bool = copy[y + 1][x - 1]
			var down_right: bool = copy[y + 1][x + 1]

			if up and left and up_left:
				forest_grid[y][x] = true
			elif up and right and up_right:
				forest_grid[y][x] = true
			elif down and left and down_left:
				forest_grid[y][x] = true
			elif down and right and down_right:
				forest_grid[y][x] = true

func remove_diagonal_bridges() -> void:
	var copy := []

	for y in range(WORLD_HEIGHT):
		var row := []
		for x in range(WORLD_WIDTH):
			row.append(forest_grid[y][x])
		copy.append(row)

	for y in range(1, WORLD_HEIGHT - 1):
		for x in range(1, WORLD_WIDTH - 1):
			if not copy[y][x]:
				continue

			var up: bool = copy[y - 1][x]
			var down: bool = copy[y + 1][x]
			var left: bool = copy[y][x - 1]
			var right: bool = copy[y][x + 1]

			# Remove cells that form a 1-tile diagonal / skinny elbow.
			# These are the shapes that your forest tileset cannot draw cleanly.
			if up and right and not down and not left:
				forest_grid[y][x] = false
			elif up and left and not down and not right:
				forest_grid[y][x] = false
			elif down and right and not up and not left:
				forest_grid[y][x] = false
			elif down and left and not up and not right:
				forest_grid[y][x] = false

func remove_skinny_forest_parts() -> void:
	var copy := []

	for y in range(WORLD_HEIGHT):
		var row := []
		for x in range(WORLD_WIDTH):
			row.append(forest_grid[y][x])
		copy.append(row)

	for y in range(1, WORLD_HEIGHT - 1):
		for x in range(1, WORLD_WIDTH - 1):
			if not copy[y][x]:
				continue

			var up: bool = copy[y - 1][x]
			var down: bool = copy[y + 1][x]
			var left: bool = copy[y][x - 1]
			var right: bool = copy[y][x + 1]

			var vertical_width := int(left) + 1 + int(right)
			var horizontal_height := int(up) + 1 + int(down)

			# Remove cells that are part of a 1-tile-wide vertical or horizontal strip.
			if vertical_width <= 1:
				forest_grid[y][x] = false
			elif horizontal_height <= 1:
				forest_grid[y][x] = false

func build_forest_grid() -> void:
	generate_forest(WORLD_WIDTH, WORLD_HEIGHT)

func generate_forest(width: int, height: int) -> void:
	forest_grid.clear()

	for y in range(height):
		var row := []
		for x in range(width):
			row.append(false)
		forest_grid.append(row)

	# 1. Always build outer forest border
	add_forest_rect(0, 0, width - 1, 3)
	add_forest_rect(0, height - 4, width - 1, height - 1)
	add_forest_rect(0, 0, 3, height - 1)
	add_forest_rect(width - 4, 0, width - 1, height - 1)

	# 2. Split interior into random density regions
	var regions := build_forest_regions(
		Rect2i(4, 4, width - 8, height - 8),
		8
	)

	# 3. Fill each density region according to its type
	for region in regions:
		fill_forest_region(region)

	# 4. Cleanup
	fill_diagonal_bites()
	fill_diagonal_bites()

	remove_single_tile_juts()
	remove_single_tile_juts()

	fill_one_tile_gaps()
	fill_one_tile_gaps()

func choose_forest_zone_type() -> int:
	var roll := randf()

	if roll < 0.2:
		return FOREST_ZONE_MEADOW
	elif roll < 0.7:
		return FOREST_ZONE_PEPPER

	return FOREST_ZONE_DENSE

func fill_meadow_region(rect: Rect2i) -> void:
	# Mostly grass. Maybe a couple tiny blobs.
	var blob_count := randi_range(0, 2)

	for i in range(blob_count):
		var center := random_point_in_rect(rect, 2)

		add_forest_blob(
			center,
			randi_range(2, 4),
			randi_range(2, 3)
		)

func fill_dense_forest_region(rect: Rect2i) -> void:
	var area := rect.size.x * rect.size.y
	var blob_count : int = max(3, int(area / 45))

	for i in range(blob_count):
		var center := random_point_in_rect(rect, 3)

		add_forest_blob(
			center,
			randi_range(4, 8),
			randi_range(3, 6)
		)

func random_point_in_rect(rect: Rect2i, margin: int = 0) -> Vector2i:
	return Vector2i(
		randi_range(rect.position.x + margin, rect.position.x + rect.size.x - 1 - margin),
		randi_range(rect.position.y + margin, rect.position.y + rect.size.y - 1 - margin)
	)

func add_pepper_tree(top_left: Vector2i, tree_size: Vector2i) -> void:
	for y in range(top_left.y, top_left.y + tree_size.y):
		for x in range(top_left.x, top_left.x + tree_size.x):
			set_forest(x, y, true)

func fill_pepper_forest_region(rect: Rect2i) -> void:
	var area: int = rect.size.x * rect.size.y
	var target_tree_count: int = max(8, int(area / 14))
	var attempts: int = target_tree_count * 8

	var size_options := [
		Vector2i(2, 2),
		Vector2i(3, 2),
		Vector2i(2, 3)
	]

	var placed := 0

	for i in range(attempts):
		if placed >= target_tree_count:
			break

		var tree_size: Vector2i = size_options.pick_random()

		var top_left := Vector2i(
			randi_range(rect.position.x, rect.position.x + rect.size.x - tree_size.x),
			randi_range(rect.position.y, rect.position.y + rect.size.y - tree_size.y)
		)

		if can_place_pepper_tree(top_left, tree_size, 2):
			add_pepper_tree(top_left, tree_size)
			placed += 1

func can_place_pepper_tree(top_left: Vector2i, tree_size: Vector2i, buffer: int = 1) -> bool:
	for y in range(top_left.y - buffer, top_left.y + tree_size.y + buffer):
		for x in range(top_left.x - buffer, top_left.x + tree_size.x + buffer):
			if is_forest(x, y):
				return false

	return true

func fill_forest_region(rect: Rect2i) -> void:
	var zone_type := choose_forest_zone_type()

	match zone_type:
		FOREST_ZONE_MEADOW:
			fill_meadow_region(rect)

		FOREST_ZONE_PEPPER:
			fill_pepper_forest_region(rect)

		FOREST_ZONE_DENSE:
			fill_dense_forest_region(rect)

func add_forest_rect(left: int, top: int, right: int, bottom: int) -> void:
	for y in range(top, bottom + 1):
		for x in range(left, right + 1):
			set_forest(x, y, true)


func clear_forest_rect(left: int, top: int, right: int, bottom: int) -> void:
	for y in range(top, bottom + 1):
		for x in range(left, right + 1):
			set_forest(x, y, false)


func add_forest_blob(center: Vector2i, radius_x: int, radius_y: int) -> void:
	for y in range(center.y - radius_y, center.y + radius_y + 1):
		for x in range(center.x - radius_x, center.x + radius_x + 1):
			var dx := float(x - center.x) / float(radius_x)
			var dy := float(y - center.y) / float(radius_y)
			var distance := dx * dx + dy * dy

			if distance < 1.0 + randf_range(-0.18, 0.18):
				set_forest(x, y, true)


func set_forest(x: int, y: int, value: bool) -> void:
	if x < 0 or y < 0 or x >= WORLD_WIDTH or y >= WORLD_HEIGHT:
		return

	forest_grid[y][x] = value


func draw_forest() -> void:
	forest_layer.clear()

	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			if forest_grid[y][x]:
				var cell := Vector2i(x, y)
				var tile := get_forest_tile(x, y)
				forest_layer.set_cell(cell, SOURCE_ID, tile)


func get_forest_tile(x: int, y: int) -> Vector2i:
	var up := is_forest(x, y - 1)
	var down := is_forest(x, y + 1)
	var left := is_forest(x - 1, y)
	var right := is_forest(x + 1, y)

	var up_left := is_forest(x - 1, y - 1)
	var up_right := is_forest(x + 1, y - 1)
	var down_left := is_forest(x - 1, y + 1)
	var down_right := is_forest(x + 1, y + 1)

		# Diagonal joins / stair-step corners
	if up and right and not up_right and not left:
		return FOREST["diagonal_bottom_right_to_top_left"]

	if up and left and not up_left and not right:
		return FOREST["diagonal_bottom_left_to_top_right"]

	# Outer corners of the forest blob
	if not up and not left:
		return FOREST["corner_top_left"]
	if not up and not right:
		return FOREST["corner_top_right"]
	if not down and not left:
		return FOREST["corner_bottom_left"]
	if not down and not right:
		return FOREST["corner_bottom_right"]

	# Edges
	if not up:
		return FOREST["edge_top"]
	if not down:
		return FOREST["edge_bottom"]
	if not left:
		return FOREST["edge_left"]
	if not right:
		return FOREST["edge_right"]

	# Inner corners / concave notches
	if up and left and not up_left:
		return FOREST["inner_corner_top_left"]
	if up and right and not up_right:
		return FOREST["inner_corner_top_right"]
	if down and left and not down_left:
		return FOREST["inner_corner_bottom_left"]
	if down and right and not down_right:
		return FOREST["inner_corner_bottom_right"]

	return FOREST["fill_1"]


func is_forest(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= WORLD_WIDTH or y >= WORLD_HEIGHT:
		return false

	return forest_grid[y][x]
