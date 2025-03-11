extends Area2D
@export var id: int
var pickable = false

func _process(delta):
	if Input.is_action_just_pressed("interact") and pickable:
		Global.picked(self)
		Global._pickup_item(id)

func _on_body_entered(body):
	if body.name == "player":
		$"../../player/Camera2D/CanvasLayer/notification/PanelContainer/RichTextLabel".text = "Press [color=gold][F][/color] to pick up"
		pickable = true
		
func _on_body_exited(body):
	if body.name == "player":
		$"../../player/Camera2D/CanvasLayer/notification/PanelContainer/RichTextLabel".text = ""
		pickable = false
