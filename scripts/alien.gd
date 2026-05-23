extends CharacterBody2D

@export var max_health := 3
@export var speed := 40.0
@export var contact_damage := 4

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_shape: CollisionShape2D = $enemyfeet
@export var hurt_time := 0.25
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var contact_hitbox: Area2D = $Hitbox
@onready var contact_shape: CollisionShape2D = $Hitbox/CollisionShape2D



var hurt := false
var health := max_health
var dead := false
var direction := Vector2.ZERO

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	contact_hitbox.add_to_group("enemy_hitboxes")
	add_to_group("enemies")
	pick_new_direction()

func _physics_process(_delta: float) -> void:
	if dead:
		return

	if hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = direction * speed
	move_and_slide()
	update_animation()

	if get_slide_collision_count() > 0:
		pick_new_direction()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area.name == "AttackHitbox":
		print("took damage from sword")
		take_damage(1)
		return

	if area.is_in_group("player_projectiles"):
		print("took damage from fireblast")

		if area.has_method("impact"):
			area.impact()

		take_damage(1)
		return

func pick_new_direction() -> void:
	direction = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()

func update_animation() -> void:
	if dead:
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("walkright")
		else:
			anim.play("walkleft")
	else:
		if direction.y > 0:
			anim.play("walkdown")
		else:
			anim.play("walkup")


func take_damage(amount: int) -> void:
	if dead or hurt:
		return

	health -= amount

	if health <= 0:
		die()
		return

	show_hurt()

func show_hurt() -> void:
	hurt = true
	anim.modulate = Color(1.0, 0.35, 0.35)

	await get_tree().create_timer(hurt_time).timeout

	if dead:
		return

	anim.modulate = Color.WHITE
	hurt = false

func die() -> void:
	dead = true

	body_shape.set_deferred("disabled", true)
	hurtbox_shape.set_deferred("disabled", true)
	contact_shape.set_deferred("disabled", true)

	queue_free()
