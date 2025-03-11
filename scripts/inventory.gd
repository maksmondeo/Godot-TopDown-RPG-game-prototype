extends Node2D

@onready var grid_container = $GridContainer
@export var slots = []
var current_slot = null
var dragged_item_texture = null
var original_slot = null
var dragged_texture_rect = null
var items = {
	"0": "Crimson",
	"1": "Zolty"
}

func _ready():
	for i in grid_container.get_children():
		slots.append(i)
	for i in self.get_children():
		if i.name.begins_with("Slot"):
			slots.append(i)
	
	for slot in slots:
		slot.mouse_entered.connect(_on_mouse_entered.bind(slot))
		slot.mouse_exited.connect(_on_mouse_exited)
		slot.gui_input.connect(_on_gui_input.bind(slot))
		if Global.inv_items[slot.name] != "":
			slot.texture = load("res://assets/items/" + Global.inv_items[slot.name] + ".png")
	dragged_texture_rect = TextureRect.new()
	dragged_texture_rect.modulate = Color(1, 1, 1, 0.5)
	dragged_texture_rect.visible = false
	dragged_texture_rect.mouse_filter = 2
	add_child(dragged_texture_rect)

func _on_mouse_entered(slot): 
	current_slot = slot
	if current_slot.texture != null:
		var path = current_slot.texture.resource_path.split("/")
		var filename = path[-1]
		$"../item_desc/PanelContainer/RichTextLabel".text = items[filename.split(".")[0]]

func _on_mouse_exited():
	current_slot = null
	$"../item_desc/PanelContainer/RichTextLabel".text = ""
	
func _on_gui_input(event, slot):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_slot_clicked(slot)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if current_slot != null:
				_on_slot_released(current_slot)
			else:
				_on_slot_released(slot)
	elif event is InputEventMouseMotion:
		_update_dragged_texture_position(event)

func _on_slot_clicked(slot):
	if slot.texture != null:
		dragged_item_texture = slot.texture
		original_slot = slot
		slot.texture = null
		dragged_texture_rect.position = get_local_mouse_position() - Vector2(8, 8)
		dragged_texture_rect.texture = dragged_item_texture
		dragged_texture_rect.visible = true

func _on_slot_released(slot):
	if dragged_item_texture != null and slot != original_slot:
		original_slot.texture = slot.texture
		slot.texture = dragged_item_texture
		dragged_item_texture = null
		original_slot = null
	elif dragged_item_texture != null and slot == original_slot:
		slot.texture = dragged_item_texture
		dragged_item_texture = null
		original_slot = null
	dragged_texture_rect.visible = false
		
func _update_dragged_texture_position(event):
	if dragged_texture_rect.visible:
		dragged_texture_rect.position = get_local_mouse_position() - Vector2(8, 8)

func _add_item(item):
	for i in range(16):
		if slots[i].texture == null:
			slots[i].texture = load("res://assets/items/" + str(item) + ".png")
			break
