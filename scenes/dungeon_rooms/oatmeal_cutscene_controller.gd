extends Node2D



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

	await dialogue.display("./oatmeal_text.json", "oatmeal_0", [], true)

	#var answer = await dialogue.display("./oatmeal_text.json", "pot_choice", [], true)


	#get_tree().paused = true
#
	#get_tree().paused = false


	#if answer == "lots":
		#await dialogue.display("./test_text.json", "pot_yes", [], true)
	#else:
		#await dialogue.display("./test_text.json", "pot_no", [], true)
