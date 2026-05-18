extends CharacterBody2D

@export var speed := 150.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var facing := "down"
var attacking := false
var attack_direction := "down"
const ATTACK_OFFSET := 10

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	attack_shape.disabled = true
	attack_hitbox.monitoring = true
	attack_hitbox.monitorable = true


func _physics_process(_delta):
	handle_movement()
	handle_attack()
	update_animation()


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
