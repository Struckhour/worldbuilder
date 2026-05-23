extends Area2D

@export var speed := 180.0
@export var lifetime := 3.0
@export var contact_damage := 1
@export var rotation_speed := 8.0

var direction := Vector2.RIGHT
var impacted := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox_area: Area2D = $hitbox_area
@onready var hitbox_collision: CollisionShape2D = $hitbox_area/hitbox_area_collision

func _ready() -> void:
	add_to_group("enemy_projectiles")
	hitbox_area.add_to_group("enemy_hitboxes")

	body_entered.connect(_on_body_entered)

	if anim.sprite_frames and anim.sprite_frames.has_animation("default"):
		anim.play("default")

	await get_tree().create_timer(lifetime).timeout
	if not impacted:
		queue_free()

func _physics_process(delta: float) -> void:
	if impacted:
		return

	global_position += direction.normalized() * speed * delta
	rotation += rotation_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("solid_world"):
		impact()
		return

	if body.get_parent() and body.get_parent().is_in_group("solid_world"):
		impact()
		return

func impact() -> void:
	if impacted:
		return

	impacted = true
	body_collision.set_deferred("disabled", true)
	hitbox_collision.set_deferred("disabled", true)

	if anim.sprite_frames and anim.sprite_frames.has_animation("impact"):
		anim.play("impact")
		await anim.animation_finished

	queue_free()
