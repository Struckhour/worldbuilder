extends CharacterBody2D

@export var speed := 150.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@export var max_health := 20
@onready var sword_fire: AudioStreamPlayer2D = $SwordFireAudio

var spinning := false
var facing := "down"
var attacking := false
var attack_direction := "down"
const ATTACK_OFFSET := 10
const FIREBLAST_SCENE := preload("res://scenes/fireblast.tscn")
const FIREBALL_PEACE_COST := 5
const SWORD_PEACE_COST := 5
const MIN_PEACE_TO_SHOOT := 75
const PEACE_REGEN_PER_SECOND := 5.0

var celebrating := false
var peace := 100.0


func _ready():
	add_to_group("player")
	anim.animation_finished.connect(_on_animation_finished)
	attack_shape.disabled = true
	attack_hitbox.monitoring = true
	attack_hitbox.monitorable = true
	$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta):
	regenerate_peace(delta)
			
	if celebrating:
		return
	handle_movement()
	handle_attack()
	handle_spin()
	update_animation()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitboxes"):
		var enemy := area.owner

		if enemy:
			take_damage(enemy.contact_damage, enemy.global_position)
		else:
			take_damage(1)

func spend_peace(amount: float) -> void:
	var old_peace := peace

	peace = max(peace - amount, 0.0)

	if old_peace > 0 and peace == 0:
		take_damage(1) # quarter heart

	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_peace(roundi(peace))

func regenerate_peace(delta: float) -> void:
	peace = min(peace + PEACE_REGEN_PER_SECOND * delta, 100.0)

	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_peace(roundi(peace))

func handle_spin() -> void:
	if attacking or spinning:
		return

	if Input.is_action_just_pressed("spin"):
		start_spin(facing)

func start_spin(direction: String) -> void:
	spinning = true
	facing = direction

	anim.play("spin" + direction)

var current_health := max_health
var invincible := false

func take_damage(amount: int, knockback_from: Vector2 = global_position) -> void:
	if invincible:
		return

	current_health = max(current_health - amount, 0)

	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_health(current_health)

	var knockback_dir := (global_position - knockback_from).normalized()
	velocity = knockback_dir * 300.0
	move_and_slide()

	invincible = true

	for i in 6:
		anim.visible = false
		await get_tree().create_timer(0.08).timeout
		anim.visible = true
		await get_tree().create_timer(0.08).timeout

	invincible = false

	if current_health <= 0:
		die()

func die() -> void:
	print("player dead")

func direction_string_to_vector(direction: String) -> Vector2:
	match direction:
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		_:
			return Vector2.DOWN

func shoot_fireblast() -> void:
	if peace < MIN_PEACE_TO_SHOOT:
		return

	spend_peace(FIREBALL_PEACE_COST)

	var fireblast := FIREBLAST_SCENE.instantiate()

	fireblast.global_position = attack_hitbox.global_position
	fireblast.direction = direction_string_to_vector(attack_direction)

	get_parent().add_child(fireblast)

func handle_movement() -> void:
	var x_input := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_input := Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	var input_dir := Vector2(x_input, y_input)

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		update_facing(x_input, y_input)

	velocity = input_dir * speed
	move_and_slide()


func update_facing(x_input: float, y_input: float) -> void:
	# Keep existing facing when moving diagonally
	if x_input != 0 and y_input != 0:
		return

	if x_input > 0:
		facing = "right"
	elif x_input < 0:
		facing = "left"
	elif y_input > 0:
		facing = "down"
	elif y_input < 0:
		facing = "up"


func handle_attack() -> void:
	if attacking or spinning:
		return

	if Input.is_action_just_pressed("attack"):
		spend_peace(SWORD_PEACE_COST)
		start_attack(facing)

func position_attack_hitbox(direction: String) -> void:
	match direction:
		"left":
			attack_hitbox.position = Vector2(-ATTACK_OFFSET, -9)
			attack_hitbox.rotation_degrees = 0

		"right":
			attack_hitbox.position = Vector2(ATTACK_OFFSET, -9)
			attack_hitbox.rotation_degrees = 0

		"up":
			attack_hitbox.position = Vector2(0, -ATTACK_OFFSET-9)
			attack_hitbox.rotation_degrees = 90

		"down":
			attack_hitbox.position = Vector2(0, ATTACK_OFFSET-9)
			attack_hitbox.rotation_degrees = 90
			
func start_attack(direction: String) -> void:
	attacking = true
	attack_direction = direction
	facing = direction

	position_attack_hitbox(direction)

	attack_shape.disabled = false
	sword_fire.play()
	anim.play("attack" + attack_direction)
	shoot_fireblast()

func _on_animation_finished() -> void:
	if anim.animation.begins_with("attack"):
		attacking = false
		attack_shape.disabled = true

	elif anim.animation.begins_with("spin"):
		spinning = false

	else:
		return

	if velocity.length() > 0:
		anim.play("walk" + facing)
	else:
		anim.stop()


func update_animation() -> void:
	# Attack animation overrides walk animation,
	# but movement still continues because handle_movement keeps running.
	if attacking or spinning:
		return

	if velocity.length() == 0:
		anim.stop()
		return

	anim.play("walk" + facing)


func _on_mage_died() -> void:
	celebrating = true
	attacking = false
	spinning = false
	attack_shape.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	anim.play("celebrate")
