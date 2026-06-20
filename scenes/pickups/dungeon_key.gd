extends Node2D

@export var door_id := ""

@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	pick_up()

func pick_up() -> void:
	print("Picked up key for door: ", door_id)

	# Unlock the door permanently.
	DungeonState.set_door_state(door_id, "closed")

	# Update any matching door already loaded in this room.
	for door in get_tree().get_nodes_in_group("doors"):
		if door.door_id == door_id:
			door.unlock()

	queue_free()
