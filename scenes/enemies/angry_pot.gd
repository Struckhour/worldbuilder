extends CharacterBody2D

@export var max_health := 3
@export var move_speed := 140.0
@export var jump_height := 48.0
@export var jump_duration := 0.5
@export var wait_time := 0.05
@export var contact_damage := 4

@onready var body_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox

@onready var body_shape: CollisionShape2D = $enemyfeet
@export var hurt_time := 0.25
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var contact_hitbox: Area2D = $Hitbox
@onready var contact_shape: CollisionShape2D = $Hitbox/CollisionShape2D

signal shattered(spawn_position: Vector2)
signal intro_animation_finished

var boss_active := false

var hurt := false
var dead := false
var health := max_health
var jumping := false
var target_position := Vector2.ZERO
var hitbox_offset := -25
var sprite_offset := -20

func _ready() -> void:
	add_to_group("enemies")
	contact_hitbox.add_to_group("enemy_hitboxes")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	body_sprite.position.y = sprite_offset
	hurtbox.position.y = hitbox_offset
	hitbox.position.y = hitbox_offset

	body_sprite.play("default")

func jump_loop() -> void:
	while boss_active and not dead:
		await get_tree().create_timer(wait_time).timeout
		await do_jump()

func play_intro_animation() -> void:
	body_sprite.play("turn")
	await body_sprite.animation_finished
	intro_animation_finished.emit()

func start_fight() -> void:
	if boss_active:
		return

	boss_active = true
	call_deferred("jump_loop")

func choose_target() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		target_position = player.global_position
	else:
		target_position = global_position + Vector2.RIGHT.rotated(randf() * TAU) * 80.0

func do_jump() -> void:
	if dead:
		return

	jumping = true

	body_sprite.play("bounce")
	await body_sprite.animation_finished

	if dead:
		return

	choose_target()
	var destination := target_position

	var start := global_position
	var elapsed := 0.0

	while elapsed < jump_duration:
		if dead:
			return

		var t := elapsed / jump_duration

		global_position = start.lerp(destination, t)

		var arc := sin(t * PI)
		body_sprite.position.y = -arc * jump_height + sprite_offset
		hurtbox.position.y = -arc * jump_height + hitbox_offset
		hitbox.position.y = -arc * jump_height + hitbox_offset

		var shadow_amount := 1.0 - arc
		shadow_sprite.scale = Vector2.ONE * lerp(0.55, 1.0, shadow_amount)
		shadow_sprite.modulate.a = lerp(0.25, 0.65, shadow_amount)

		elapsed += get_process_delta_time()
		await get_tree().process_frame

	if dead:
		return

	global_position = destination
	body_sprite.position.y = sprite_offset
	hurtbox.position.y = hitbox_offset
	hitbox.position.y = hitbox_offset
	shadow_sprite.scale = Vector2.ONE
	shadow_sprite.modulate.a = 0.65

	if dead:
		return

	body_sprite.play("smoke_burst")
	await body_sprite.animation_finished

	if dead:
		return

	jumping = false
	
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Pot hurtbox touched by area: ", area.name, " groups: ", area.get_groups())
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
	body_sprite.modulate = Color(1.0, 0.35, 0.35)

	await get_tree().create_timer(hurt_time).timeout

	if dead:
		return

	body_sprite.modulate = Color.WHITE
	hurt = false

func die() -> void:
	if dead:
		return

	dead = true
	boss_active = false
	jumping = false

	body_sprite.stop()
	body_sprite.position.y = sprite_offset
	hurtbox.position.y = hitbox_offset
	hitbox.position.y = hitbox_offset

	body_sprite.play("shatter")
	await body_sprite.animation_finished

	var wizard_spawn_position := global_position
	shattered.emit(wizard_spawn_position)

	shadow_sprite.visible = false
	body_shape.set_deferred("disabled", true)
	hurtbox_shape.set_deferred("disabled", true)
	contact_shape.set_deferred("disabled", true)
	#queue_free()
