extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var dead := false

@export var drift_speed := 7.0
@export var wobble_amount := 10.0
@export var wobble_speed := 1.2
@export var turn_speed := 0.6
@export var float_rotation_speed := 20.0

var t := 0.0
var drift_dir := Vector2.ZERO
var base_position := Vector2.ZERO
var phase := 0.0
func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)
	anim.play("idle")
	base_position = global_position
	t = randf_range(0.0, TAU)
	phase = randf_range(0.0, TAU)
	drift_dir = Vector2(randf_range(-1, 1), randf_range(-0.6, 0.6)).normalized()
	

func _on_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area.name == "AttackHitbox":
		die()

func _on_body_entered(body: Node2D) -> void:
	if dead:
		return

	if body.has_method("take_damage"):
		body.take_damage(1)

func die() -> void:
	dead = true

	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

	anim.play("death")


func _on_animation_finished() -> void:
	if anim.animation == "death":
		queue_free()
		
func _physics_process(delta: float) -> void:
	if dead:
		return

	t += delta

	# Slowly change direction over time, like air currents.
	drift_dir = drift_dir.rotated(sin(t * 0.7 + phase) * turn_speed * delta)
	drift_dir = drift_dir.normalized()

	base_position += drift_dir * drift_speed * delta

	var wobble := Vector2(
		sin(t * wobble_speed + phase) * wobble_amount,
		cos(t * wobble_speed * 0.8 + phase) * wobble_amount * 0.6
	)

	global_position = base_position + wobble

	rotation_degrees += float_rotation_speed * delta
