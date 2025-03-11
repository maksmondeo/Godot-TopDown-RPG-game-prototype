extends TextureProgressBar
@export var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player.health_changed.connect(update)
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	max_value = player.max_health
	value = player.health
