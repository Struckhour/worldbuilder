extends CharacterBody2D

@export var move_speed := 90.0
@export var jump_height := 48.0
@export var jump_duration := 0.8
@export var wait_time := 0.4
@export var contact_damage := 4

@onready var body_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox

var jumping := false
var target_position := Vector2.ZERO

func _ready() -> void:
	add_to_group("enemies")
	body_sprite.play("turn")
	call_deferred("jump_loop")

func jump_loop() -> void:
	while true:
		await get_tree().create_timer(wait_time).timeout
		choose_target()
		await do_jump(target_position)

func choose_target() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		target_position = player.global_position
	else:
		target_position = global_position + Vector2.RIGHT.rotated(randf() * TAU) * 80.0

func do_jump(destination: Vector2) -> void:
	jumping = true
	body_sprite.play("bounce")
	await body_sprite.animation_finished
	var start := global_position
	var elapsed := 0.0

	while elapsed < jump_duration:
		var t := elapsed / jump_duration

		global_position = start.lerp(destination, t)

		var arc := sin(t * PI)
		body_sprite.position.y = -arc * jump_height

		var shadow_amount := 1.0 - arc
		shadow_sprite.scale = Vector2.ONE * lerp(0.55, 1.0, shadow_amount)
		shadow_sprite.modulate.a = lerp(0.25, 0.65, shadow_amount)

		elapsed += get_process_delta_time()
		await get_tree().process_frame

	global_position = destination
	body_sprite.position.y = 0.0
	shadow_sprite.scale = Vector2.ONE
	shadow_sprite.modulate.a = 0.65

	jumping = false
