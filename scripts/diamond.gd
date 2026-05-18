extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var dead := false

@export var move_radius := 60.0
@export var move_speed := 1.5
@export var drift_speed := 18.0

var center := Vector2.ZERO
var t := 0.0
var phase_a := 0.0
var phase_b := 0.0
var drift_dir := Vector2.ZERO
func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)

	center = global_position
	t = randf_range(0.0, TAU)
	phase_a = randf_range(0.0, TAU)
	phase_b = randf_range(0.0, TAU)
	drift_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	

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

	t += move_speed * delta
	center += drift_dir * drift_speed * delta

	var offset := Vector2(
		cos(t + phase_a) * move_radius + cos(t * 2.3) * move_radius * 0.35,
		sin(t * 1.4 + phase_b) * move_radius * 0.7 + sin(t * 2.1) * move_radius * 0.25
	)

	global_position = center + offset
	rotation_degrees += 120.0 * delta
