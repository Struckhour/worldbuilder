extends CharacterBody2D

@export var speed := 180.0
@export var lifetime := 10.0
@export var contact_damage := 4
@export var max_bounces := 6

@onready var hitbox_area: Area2D = $HitboxArea

var direction := Vector2.RIGHT
var bounces := 0
var hit_player := false
var just_spawned := true

func _ready() -> void:
	hitbox_area.add_to_group("enemy_hitboxes")
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	just_spawned = false
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction.normalized() * speed * delta)

	if collision and not just_spawned:
		direction = direction.bounce(collision.get_normal()).normalized()
		bounces += 1

		if bounces >= max_bounces:
			queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if hit_player:
		return

	if area.is_in_group("player_hurtbox"):
		hit_player = true
		queue_free()
