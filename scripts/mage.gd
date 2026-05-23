extends CharacterBody2D

@export var max_health := 3
@export var speed := 200.0
@export var contact_damage := 4

@export var enemy_projectile_scene: PackedScene
@export var projectile_speed := 280.0
@export var projectile_lifetime := 3.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_shape: CollisionShape2D = $enemyfeet
@export var hurt_time := 0.25
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var contact_hitbox: Area2D = $Hitbox
@onready var contact_shape: CollisionShape2D = $Hitbox/CollisionShape2D

@export var teleport_interval := 1.0
@export var teleport_attempts := 100
@export var teleport_padding_tiles := 2

@export var mage_area_top_left := Vector2(200, 50)
@export var mage_area_bottom_right := Vector2(650, 270)
@export var min_player_distance := 96.0
@onready var poof_sfx: AudioStreamPlayer2D = $PoofAudio
@onready var poof_reverse_sfx: AudioStreamPlayer2D = $PoofReverseAudio
@onready var scurry_sfx: AudioStreamPlayer2D = $ScurryAudio
var teleporting := false

var hurt := false
var health := max_health
var dead := false
var direction := Vector2.ZERO

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	contact_hitbox.add_to_group("enemy_hitboxes")
	add_to_group("enemies")
	pick_new_direction()
	teleport_loop()

func _physics_process(_delta: float) -> void:
	if dead:
		return

	if hurt or teleporting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = direction * speed
	move_and_slide()
	update_animation()
	if velocity.length() > 0 and not teleporting and not dead:
		if not scurry_sfx.playing:
			scurry_sfx.play()
	else:
		scurry_sfx.stop()

	if get_slide_collision_count() > 0:
		pick_new_direction()

func teleport_loop() -> void:
	while not dead:
		await get_tree().create_timer(teleport_interval).timeout

		if dead:
			return
		shoot_projectile_burst()
		await teleport()


func teleport() -> void:
	if dead or hurt or teleporting:
		return

	teleporting = true
	velocity = Vector2.ZERO

	contact_shape.set_deferred("disabled", true)

	# Poof out at old location.
	poof_sfx.play()
	anim.play("poof")
	await anim.animation_finished

	visible = false

	var new_pos := await find_valid_teleport_position()
	global_position = new_pos

	await get_tree().physics_frame

	visible = true
	pick_new_direction()
	shoot_projectile_burst()
	# Poof in at new location.
	poof_reverse_sfx.play()
	anim.play("poof")
	await anim.animation_finished

	if dead:
		return

	contact_shape.set_deferred("disabled", false)
	teleporting = false


func find_valid_teleport_position() -> Vector2:
	for attempt in range(teleport_attempts):
		var pos := random_play_area_position()

		if await is_valid_teleport_position(pos):
			return pos

	return global_position


func random_play_area_position() -> Vector2:
	return Vector2(
		randf_range(mage_area_top_left.x, mage_area_bottom_right.x),
		randf_range(mage_area_top_left.y, mage_area_bottom_right.y)
	)

func is_valid_teleport_position(pos: Vector2) -> bool:
	var player := get_tree().get_first_node_in_group("player")

	if player:
		if pos.distance_to(player.global_position) < min_player_distance:
			return false

	var old_pos := global_position

	global_position = pos
	await get_tree().physics_frame

	var collision := move_and_collide(Vector2.ZERO, true)

	global_position = old_pos

	return collision == null

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

func shoot_projectile_burst() -> void:
	if enemy_projectile_scene == null:
		print("No enemy_projectile_scene assigned on mage")
		return

	var directions := [
		Vector2.RIGHT,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2(1, 1).normalized(),
		Vector2(1, -1).normalized(),
		Vector2(-1, 1).normalized(),
		Vector2(-1, -1).normalized()
	]

	for dir in directions:
		var projectile := enemy_projectile_scene.instantiate()

		projectile.global_position = global_position
		projectile.direction = dir
		projectile.speed = projectile_speed
		projectile.lifetime = projectile_lifetime

		get_tree().current_scene.add_child(projectile)
