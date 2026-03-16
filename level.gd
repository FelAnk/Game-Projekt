extends Node2D

@onready var pathFollow = %CameraPath/PathFollow2d

func _process(delta: float) -> void:
	print(pathFollow.progress_ratio)
