extends CharacterBody2D

enum State {
	GROUND, 
	JUMP, 
	FALL,
	}

@export_category("Jump")
@export_range(10.0, 200.0) var jump_height := 50.0
@export_range(0.1, 1.5) var jump_time_to_peak := 0.35


@export var acceleration := 1000.0
@export var deceleration := 2500.0
@export var max_speed := 1000.0
@export var air_acceleration := 900.0
@export var max_fall_speed:= 1000.0


var current_state: State = State.GROUND
var direction_x := 0.0
var current_gravity := 0.0

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

@onready var jump_speed := calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity := calcultate_jump_gravity(jump_height, jump_time_to_peak)


func _ready() -> void:
	_transition_to_state(current_state)

func _physics_process(delta: float) -> void:
	
	direction_x = signf(Input.get_axis("move_left","move_right"))
	
	match current_state:
		State.GROUND: 
			process_ground_state(delta)
		State.JUMP:
			process_jump_state(delta)
		State.FALL: 
			process_fall_state(delta)

	velocity.y += current_gravity * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	move_and_slide()

func process_ground_state(delta: float) -> void:
	var is_moving := absf(direction_x) > 0.0
	if is_moving: 
		velocity.x += direction_x * acceleration * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		
		animated_sprite.flip_h = direction_x < 0.0
		animated_sprite.play("Run")
		
	else: 
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		animated_sprite.play("Stand")
	
	
	
	
	if Input.is_action_just_pressed("jump"):
		_transition_to_state(State.JUMP)
	elif not is_on_floor():
		_transition_to_state(State.FALL)
		

func process_jump_state(delta: float) -> void:
	if direction_x != 0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		animated_sprite.flip_h = direction_x < 0.0
		
	if velocity.y >= 0.0:
		_transition_to_state(State.FALL)

func process_fall_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		animated_sprite.flip_h = direction_x < 0.0
	
	
	if is_on_floor():
		_transition_to_state(State.GROUND)


func _transition_to_state(new_state : State) -> void:
	var previous_state := current_state
	current_state = new_state
	
	#exit previous state
	match previous_state:
		pass
	
	match current_state:
		State.JUMP:
			velocity.y = jump_speed
			current_gravity = jump_gravity
			animated_sprite.play("Jump")
		State.FALL: 
			animated_sprite.play("Falling")

func calculate_jump_speed(height:float, time_to_peak:float) -> float:
	return (-2.0 * height) / time_to_peak

func calcultate_jump_gravity(height:float, time_to_peak:float) -> float: 
	return  (2.0 * height) / pow(time_to_peak, 2.0)
