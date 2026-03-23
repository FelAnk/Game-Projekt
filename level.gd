extends Node2D

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

func _process(delta: float) -> void:
	#print(path_follow_2d.progress_ratio)
	path_follow_2d.progress_ratio += 0.05 * delta
