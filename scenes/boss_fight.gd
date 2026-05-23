extends Node2D
@onready var boss_music : AudioStreamPlayer2D = $BossMusic

func _ready() -> void:
	boss_music.play()
