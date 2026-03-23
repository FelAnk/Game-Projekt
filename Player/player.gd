extends CharacterBody2D

enum State {
	GROUND, 
	JUMP, 
	FALL,
	DEATH
	}

@export_category("Jump")
@export_range(10.0, 600.0) var jump_height := 250.0
@export_range(0.1, 2.5) var jump_time_to_peak := 0.50
@export_range(0.1, 1.5) var jump_time_to_decent := 0.15
@export_range(50.0, 2000.0) var jump_horizontal_distance := 300.0
@export_range(5.0, 500.0)var jump_cut_divider:= 150.0


@export var acceleration := 10000.0
@export var deceleration := 2800.0
@export var max_speed := 500.0
@export var air_acceleration := 900.0
@export var max_fall_speed:= 500.0


var current_state: State = State.GROUND
var direction_x := 0.0
var current_gravity := 0.0

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var cayote_timer := Timer.new()
@onready var jump_speed := calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity := calcultate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity := calculate_fall_gravity(jump_height, jump_time_to_decent)
@onready var jump_horizontal_speed := calculate_jump_horizontal_speed(jump_horizontal_distance, jump_time_to_peak, jump_time_to_decent)

func _ready() -> void:
	_transition_to_state(current_state)
	cayote_timer.wait_time = 0.2
	cayote_timer.one_shot = true
	add_child(cayote_timer)

func _physics_process(delta: float) -> void:
	
	direction_x = signf(Input.get_axis("move_left","move_right"))
	
	match current_state:
		State.GROUND: 
			process_ground_state(delta)
		State.JUMP:
			process_jump_state(delta)
		State.FALL: 
			process_fall_state(delta)
		State.DEATH:
			process_death_state(delta)

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
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		animated_sprite.flip_h = direction_x < 0.0
	
	if Input.is_action_just_pressed("jump"):
		var jump_cut_speed := jump_speed / jump_cut_divider
		if velocity.y < 0.0 and velocity.y < jump_cut_speed:
			velocity.y = jump_cut_speed
	
	if velocity.y >= 0.0:
		_transition_to_state(State.FALL)

func process_fall_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		animated_sprite.flip_h = direction_x < 0.0
	
	if is_on_floor():
		_transition_to_state(State.GROUND)

func process_death_state(delta: float) -> void:
	pass


func _transition_to_state(new_state : State) -> void:
	var previous_state := current_state
	current_state = new_state
	
	#exit previous state
	match previous_state:
		State.FALL: 
			cayote_timer.stop()
	
	match current_state:
		State.JUMP:
			velocity.y = jump_speed
			current_gravity = jump_gravity
			velocity.x = direction_x * jump_horizontal_speed
			animated_sprite.play("Jump")
		
		State.FALL:
			animated_sprite.play("Falling") 
			current_gravity = fall_gravity
			
			if previous_state == State.GROUND:
				cayote_timer.start()

func calculate_jump_horizontal_speed(distance: float, time_to_peak: float, time_to_decent: float) -> float:
	return distance / (time_to_peak + time_to_decent)

func calculate_jump_speed(height:float, time_to_peak:float) -> float:
	return (-2.0 * height) / time_to_peak

func calcultate_jump_gravity(height:float, time_to_peak:float) -> float: 
	return  (2.0 * height) / pow(time_to_peak, 2.0)

func calculate_fall_gravity(height: float, time_to_decent: float) -> float: 
	return (2.0 * height) / pow(time_to_decent, 2.0)
