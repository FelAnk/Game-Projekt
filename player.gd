extends CharacterBody2D

@export var acceleration := 1000.0
@export var deceleration := 2000.0
@export var max_speed := 1200.0
@export var jump_gravity := 1200.0

func _physics_process(delta: float) -> void:
	var direction_x := signf(Input.get_axis("move_left","move_right"))
	
	var is_moving := absf(direction_x) > 0.0
	if is_moving: 
		velocity.x += direction_x * acceleration * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
	else: 
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
		
	velocity.y += jump_gravity * delta
	move_and_slide()
