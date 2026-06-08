extends Area2D

@export var speed := 350.0
@export var lifetime := 1.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction := Vector2.DOWN
var impacted := false

func _ready() -> void:
	anim.play("default")
	rotation = Vector2.DOWN.angle_to(direction)
	add_to_group("player_projectiles")

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	await get_tree().create_timer(lifetime).timeout
	if not impacted:
		queue_free()

func _physics_process(delta: float) -> void:
	if impacted:
		return

	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if impacted:
		return

	var target := area.owner

	if target and target.is_in_group("enemies"):
		impact()

func _on_body_entered(body: Node2D) -> void:
	if impacted:
		return

	impact()

func impact() -> void:
	impacted = true
	collision_shape.set_deferred("disabled", true)

	anim.play("burnout")
	await anim.animation_finished

	queue_free()
