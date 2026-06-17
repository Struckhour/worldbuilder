# DungeonState.gd
extends Node

var door_states := {}

func get_door_state(door_id: String) -> String:
	return door_states.get(door_id, "closed")

func set_door_state(door_id: String, state: String) -> void:
	door_states[door_id] = state

func is_door_open(door_id: String) -> bool:
	return get_door_state(door_id) == "open"

func is_door_locked(door_id: String) -> bool:
	return get_door_state(door_id) == "locked"
