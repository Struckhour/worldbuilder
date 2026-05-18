extends CharacterBody2D

@export var speed := 150.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@export var max_health := 20

var facing := "down"
var attacking := false
var attack_direction := "down"
const ATTACK_OFFSET := 10
const FIREBLAST_SCENE := preload("res://scenes/fireblast.tscn")

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	attack_shape.disabled = true
	attack_hitbox.monitoring = true
	attack_hitbox.monitorable = true


func _physics_process(_delta):
	handle_movement()
	handle_attack()
	update_animation()


var current_health := max_health
var invincible := false

func take_damage(amount: int) -> void:
	if invincible:
		return

	current_health = max(current_health - amount, 0)

	var hud := get_tree().get_first_node_in_group("hud")

	if hud:
		hud.set_health(current_health)

	invincible = true
	await get_tree().create_timer(0.75).timeout
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
	if attacking:
		return

	if Input.is_action_just_pressed("attackleft"):
		start_attack("left")
	elif Input.is_action_just_pressed("attackright"):
		start_attack("right")
	elif Input.is_action_just_pressed("attackup"):
		start_attack("up")
	elif Input.is_action_just_pressed("attackdown"):
		start_attack("down")

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
	anim.play("attack" + attack_direction)
	shoot_fireblast()

func _on_animation_finished() -> void:
	if anim.animation.begins_with("attack"):
		attacking = false
		attack_shape.disabled = true
		if velocity.length() > 0:
			anim.play("walk" + facing)
		else:
			anim.stop()


func update_animation() -> void:
	# Attack animation overrides walk animation,
	# but movement still continues because handle_movement keeps running.
	if attacking:
		return

	if velocity.length() == 0:
		anim.stop()
		return

	anim.play("walk" + facing)
