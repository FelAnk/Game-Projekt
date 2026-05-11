extends Control
@onready var start_button: Button = $StartButton


func _ready() -> void:
	start_button.pressed.connect(start)
	
	
func start():
	get_tree().change_scene_to_file("res://level.tscn")
	
