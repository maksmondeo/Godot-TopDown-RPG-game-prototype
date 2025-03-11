extends CharacterBody2D

const speed = 240
const accel = 5000
const friction = 1800
var max_health = 20
var health = 20
var weapon_flipped = false
var knockback = Vector2(0, 0)
var knockback_flash_tween
var knockback_tween
var queued_knockback = null
var x = 40
signal health_changed

@export var player_path: NodePath

func _ready():
	position = Global.player_spawn_location
	
func _process(delta):
	if not Global.attack_ip: #rotation of the weapon and player
		var angle = get_local_mouse_position().angle()
		var distance = min(get_local_mouse_position().length(), x)
		
		if angle < deg_to_rad(-90) or angle > deg_to_rad(90): #left
			$player_sprite.flip_h = true
			$weapon.flip_h = true
		else: #right
			$player_sprite.flip_h = false
			$weapon.flip_h = false
			
		if int($weapon.rotation/PI) % 2 == 0 and $weapon.rotation/PI < 0 or int($weapon.rotation/PI) % 2 != 0 and $weapon.rotation/PI > 0:
			$weapon.flip_h = false
			weapon_flipped = false
		else:
			$weapon.flip_h = true
			weapon_flipped = true

		$weapon.position = $weapon.position.lerp(Vector2(cos(angle) * distance, sin(angle) * distance), delta * 10)
		$weapon.rotation = lerp_angle($weapon.rotation, angle - deg_to_rad(90), delta * 10)
	
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	player_movement(input, delta)
	move_and_slide()
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index==1 and not Global.attack_ip and not Global.is_inv_open and not Global.is_atlas_open: #attack
		Global.attack_ip = true
		var slash_anim = $sword_anim_player.get_animation("slash")
		if weapon_flipped:
			$weapon/weapon_area/CollisionShape2D.position.x = -8.833
			slash_anim.track_set_key_value(0, 0, get_local_mouse_position().angle() - deg_to_rad(90))
			slash_anim.track_set_key_value(0, 1, get_local_mouse_position().angle() - deg_to_rad(50))
			slash_anim.track_set_key_value(0, 2, get_local_mouse_position().angle() - deg_to_rad(300))
			slash_anim.track_set_key_value(0, 3, get_local_mouse_position().angle() - deg_to_rad(90))
		else:
			$weapon/weapon_area/CollisionShape2D.position.x = 8.833
			slash_anim.track_set_key_value(0, 0, get_local_mouse_position().angle() - deg_to_rad(90))
			slash_anim.track_set_key_value(0, 1, get_local_mouse_position().angle() - deg_to_rad(140))
			slash_anim.track_set_key_value(0, 2, get_local_mouse_position().angle() + deg_to_rad(90))
			slash_anim.track_set_key_value(0, 3, get_local_mouse_position().angle() - deg_to_rad(90))
		$sword_anim_player.play("slash")
		await get_tree().create_timer(0.1).timeout
		var rect = RectangleShape2D.new()
		rect.extents = Vector2(16, 5)
		$weapon/weapon_area/CollisionShape2D.shape = rect
	if Input.is_action_just_pressed("view_atlas") and !Global.is_inv_open and Global.can_change_inv_view and !Global.is_atlas_open:
		Global.is_atlas_open = true
		Global.can_change_inv_view = false
		$Camera2D/CanvasLayer/atlas/atlas_anim_player.play("in")
	if Input.is_action_just_pressed("view_atlas") and !Global.is_inv_open and Global.is_atlas_open and Global.can_change_inv_view:
		Global.can_change_inv_view = false
		$Camera2D/CanvasLayer/atlas/atlas_anim_player.play("out")
	if Input.is_action_just_pressed("view_inv") and !Global.is_inv_open and Global.can_change_inv_view and !Global.is_atlas_open:
		Global.is_inv_open = true
		Global.can_change_inv_view = false
		$Camera2D/CanvasLayer/inventory/inv_anim_player.play("in")
	if Input.is_action_just_pressed("view_inv") and Global.is_inv_open and Global.can_change_inv_view and !Global.is_atlas_open:
		Global.can_change_inv_view = false
		$Camera2D/CanvasLayer/inventory/inv_anim_player.play("out")
	if Input.is_action_just_pressed("ui_cancel") and (Global.is_inv_open or Global.is_atlas_open):
		if Global.is_inv_open:
			Global.can_change_inv_view = false
			$Camera2D/CanvasLayer/inventory/inv_anim_player.play("out")
		else:
			Global.can_change_inv_view = false
			$Camera2D/CanvasLayer/atlas/atlas_anim_player.play("out")
			
		
func player_movement(input, delta):
	if knockback:
		velocity = knockback
	else:
		if input: 
			velocity = velocity.move_toward(input * speed, delta * accel)
			$player_sprite.play("walk")
			if input.x < 0 or input.x == 0 and weapon_flipped:
				$player_sprite.flip_h = true
			else:
				$player_sprite.flip_h = false
		else:
			$player_sprite.play("idle")
			velocity = velocity.move_toward(Vector2(0,0), delta * friction)

func hit(damage, knockback_strength):
	if knockback==Vector2.ZERO:
		health -= damage
		health_changed.emit()
		knockback = knockback_strength
		knockback_tween = create_tween()
		knockback_flash_tween = create_tween()
		knockback_tween.tween_property(self, "knockback", Vector2.ZERO, .3)
		$player_sprite.modulate.v = 15
		knockback_flash_tween.tween_property($player_sprite, "modulate:v", 1, .3)
		await knockback_tween.finished
		await knockback_flash_tween.finished
		_on_knockback_tween_completed()

func _on_hitbox_area_entered(area):
	if area.name == "enemy_hitbox":
		if knockback != Vector2.ZERO:
			queued_knockback = (global_position - area.global_position).normalized() * 800
		else:
			hit(1, (global_position - area.global_position).normalized() * 800)
			
func _on_knockback_tween_completed():
	if queued_knockback != null:
		hit(1, queued_knockback)
		queued_knockback = null

func _on_atlas_anim_player_animation_finished(anim_name):
	match anim_name:
		"out":
			Global.can_change_inv_view = true
			Global.is_atlas_open = false
		"in":
			Global.can_change_inv_view = true

func _on_sword_anim_player_animation_finished(anim_name):
	if anim_name == "slash":
		Global.attack_ip = false
		$weapon/weapon_area/CollisionShape2D.shape = null

func _on_inv_anim_player_animation_finished(anim_name):
	match anim_name:
		"out":
			Global.can_change_inv_view = true
			Global.is_inv_open = false
		"in":
			Global.can_change_inv_view = true
