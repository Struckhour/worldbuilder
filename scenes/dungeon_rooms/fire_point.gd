extends Node2D

@export var fire_projectile_scene: PackedScene

@export var min_fire_delay := 0.6
@export var max_fire_delay := 2.5
@export var projectile_speed := 180.0
@export var projectile_lifetime := 6.0

@export var active := true


func _ready() -> void:
	fire_loop()


func fire_loop() -> void:
	while active:
		var delay := randf_range(min_fire_delay, max_fire_delay)
		await get_tree().create_timer(delay).timeout

		if not active:
			return

		shoot()


func shoot() -> void:
	if fire_projectile_scene == null:
		push_warning("No fire_projectile_scene assigned.")
		return

	var projectile = fire_projectile_scene.instantiate()

	projectile.global_position = global_position
	projectile.z_index = 10
	projectile.direction = random_direction()
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime

	get_parent().add_child(projectile)


func random_direction() -> Vector2:
	return Vector2.RIGHT.rotated(randf() * TAU).normalized()
