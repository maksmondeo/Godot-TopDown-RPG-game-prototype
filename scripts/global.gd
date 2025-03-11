extends Node

var attack_ip = false
var player_damage = 5
var is_atlas_open = false
var is_inv_open = false
var can_change_inv_view = true
var can_change_atlas_view = true
var current_map = "0"
var picked_stuff = {}
var inv_items = {}
var player_spawn_location = Vector2.ZERO

func _ready():
	load_game()

func picked(body):
	var body_info = body.name.split("_")
	picked_stuff[body.name] = true
	body.monitoring = false
	body.get_node("Sprite2D").visible = false
	body.get_node("shadow").visible = false
	
func _pickup_item(item):
	get_node("/root/" + current_map + "/player/Camera2D/CanvasLayer/inventory")._add_item(item)
	
func save(pos_x, pos_y, inv):
	var save_dict = {
		"pos_x" : pos_x,
		"pos_y" : pos_y,
		"inventory" : inv,
		"current_map": current_map
	}
	return save_dict
	
func save_game():
	var save_file = FileAccess.open("user://savefile.save", FileAccess.WRITE)
	var player = get_tree().get_root().get_node(current_map+"/player")
	for i in get_node("/root/" + current_map + "/player/Camera2D/CanvasLayer/inventory").slots:
		if i.texture != null:
			var path = i.texture.resource_path.split("/")
			var filename = path[-1]
			inv_items[i.name] = filename.split(".")[0]
		else:
			inv_items[i.name] = ""
	var json_string = JSON.stringify(save(player.position.x, player.position.y, inv_items))
	save_file.store_line(json_string)
	
func load_game():
	if not FileAccess.file_exists("user://savefile.save"):
		return
	
	var save_file = FileAccess.open("user://savefile.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.get_data()
		Global.current_map = node_data["current_map"]
		get_tree().change_scene_to_file("res://scenes/" + current_map + ".tscn")
		player_spawn_location = Vector2(node_data["pos_x"], node_data["pos_y"])
		inv_items = node_data["inventory"]
