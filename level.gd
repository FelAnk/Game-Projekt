extends Node2D

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
@onready var pause_button: Button = %Pause_Button


func _process(delta: float) -> void:
	#print(path_follow_2d.progress_ratio)
	path_follow_2d.progress_ratio += 0.05 * delta
	Input.is_action_just_pressed("Pause") 


func pause():
	pass
