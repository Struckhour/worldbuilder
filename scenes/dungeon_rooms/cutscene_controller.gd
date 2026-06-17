extends Node2D

@onready var pot = $"../AngryPot"

var running := false

func start() -> void:
	if running:
		return

	running = true
	await run_sequence()
	running = false

func run_sequence() -> void:
	var dialogue = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue == null:
		push_warning("No dialogue_box found.")
		return

	# First dialogue. Pauses game.
	await dialogue.display("./test_text.json", "pot_0", [], true)
	var answer = await dialogue.display("./test_text.json", "pot_choice", [], true)
	print("answer: ", answer)
	if answer == "lots":
		await dialogue.display("./test_text.json", "pot_yes", [], true)
	else:
		await dialogue.display("./test_text.json", "pot_no", [], true)
	# Pot animation after first dialogue advances/finishes.
	pot.play_intro_animation()
	await pot.intro_animation_finished

	# Second dialogue.
	
	await dialogue.display("./test_text.json", "pot_1", [], true)
	# Start boss behavior.
	pot.start_fight()
