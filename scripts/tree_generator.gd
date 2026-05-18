extends Node2D

const TILE_SIZE := 16.0

const TREE_SCENES := [
	preload("res://scenes/trees/birch_tree.tscn"),
	preload("res://scenes/trees/blue_tree.tscn"),
	preload("res://scenes/trees/fir_tree.tscn"),
	preload("res://scenes/trees/maple_tree.tscn")
]

func _ready() -> void:
	print("TreeGenerator is running")

	randomize()

	for i in range(150):
		var pos := random_tree_position()
		place_random_tree(pos)

func random_tree_position() -> Vector2:
	var padding_tiles := 2

	var area := GameArea.PLAY_AREA_TILES

	var cell := Vector2i(
		randi_range(area.position.x + padding_tiles, area.end.x - 1 - padding_tiles),
		randi_range(area.position.y + padding_tiles, area.end.y - 1 - padding_tiles)
	)

	return GameArea.tile_to_world(cell)

func place_random_tree(pos: Vector2) -> void:
	var tree_scene: PackedScene = TREE_SCENES.pick_random()
	var tree := tree_scene.instantiate()

	tree.global_position = pos

	var scale_factor := randf_range(0.9, 1.1)
	tree.scale = Vector2(scale_factor, scale_factor)
	tree.add_to_group("trees")
	get_parent().add_child.call_deferred(tree)

func place_tree_at_world_position(pos: Vector2) -> void:
	var tree_scene: PackedScene = preload("res://scenes/trees/fir_tree.tscn")
	var tree := tree_scene.instantiate()

	tree.global_position = pos
	tree.add_to_group("trees")

	get_parent().add_child.call_deferred(tree)

	print("Placed tree: ", tree.name, " at ", tree.global_position)
