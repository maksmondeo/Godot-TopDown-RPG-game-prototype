extends Area2D
@onready var passage_anim_player = $"../player/Camera2D/CanvasLayer/passage_anim_player"
@onready var color_rect = $"../player/Camera2D/CanvasLayer/ColorRect"
@export var scene: String
@export var spawn_location: Vector2

func _ready():
	passage_anim_player.animation_finished.connect(anim_finished)

func _on_body_entered(body):
	if body.name == "player":
		color_rect.visible = true
		passage_anim_player.play("passage_in")
		
func anim_finished(anim_name):
	if anim_name == "passage_in":
		Global.save_game()
		Global.player_spawn_location = spawn_location
		Global.current_map = scene
		get_tree().change_scene_to_file("res://scenes/" + scene + ".tscn")
	if anim_name == "passage_out":
		color_rect.visible = false
		Global.save_game()
