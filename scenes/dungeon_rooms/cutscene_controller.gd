extends Node2D

@export var wizard_scene: PackedScene
@export var wizard_music: AudioStream

@onready var pot = $"../AngryPot"

var running := false
var wizard_spawned := false


func _ready() -> void:
	pot.shattered.connect(_on_pot_shattered)


func start() -> void:
	if running:
		return

	running = true
	await run_sequence()
	running = false


func run_sequence() -> void:
	set_door_state_by_id("b2_to_l1", "locked")

	var dialogue = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue == null:
		push_warning("No dialogue_box found.")
		return

	await dialogue.display("./test_text.json", "pot_0", [], true)

	var answer = await dialogue.display("./test_text.json", "pot_choice", [], true)

	pot.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	pot.play_intro_animation()
	await pot.intro_animation_finished

	get_tree().paused = false
	pot.process_mode = Node.PROCESS_MODE_INHERIT

	if answer == "lots":
		await dialogue.display("./test_text.json", "pot_yes", [], true)
	else:
		await dialogue.display("./test_text.json", "pot_no", [], true)

	pot.start_fight()


func _on_wizard_died() -> void:
	var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")

	if dungeon_manager and dungeon_manager.has_method("stop_music"):
		dungeon_manager.stop_music()


func _on_pot_shattered(spawn_position: Vector2) -> void:
	if wizard_spawned:
		return

	wizard_spawned = true

	var wizard = wizard_scene.instantiate()
	wizard.died.connect(_on_wizard_died)

	get_parent().add_child(wizard)

	wizard.global_position = spawn_position + Vector2(0, -25)
	wizard.scale = Vector2(1.5, 1.5)
	wizard.death_opens_door_id = "l1_to_end"

	var dialogue = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue == null:
		push_warning("No dialogue_box found.")
		return

	await dialogue.display("./test_text.json", "wizard_0", [], true)
	await dialogue.display("./test_text.json", "wizard_1", [], true)

	if wizard.has_method("start_fight"):
		var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")

		if dungeon_manager and dungeon_manager.has_method("play_music"):
			dungeon_manager.play_music(wizard_music)

		wizard.start_fight()


func set_door_state_by_id(target_id: String, state: String) -> void:
	var doors := get_tree().get_nodes_in_group("doors")

	for door in doors:
		if door.door_id != target_id:
			continue

		if door.has_method("set_state"):
			door.set_state(state)
		else:
			door.default_state = state

		return

	push_warning("No door found with id: " + target_id)
