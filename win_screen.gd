extends Control

@onready var respawn_button: Button = %RespawnButton


func _ready() -> void:
	respawn_button.pressed.connect(respawn)
	
	
func respawn():
	get_tree().change_scene_to_file("res://level.tscn")
	
