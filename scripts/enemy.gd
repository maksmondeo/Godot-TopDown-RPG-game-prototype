extends CharacterBody2D

var can_take_damage = true
var knockback = Vector2.ZERO
@export var health = 20 

func _process(delta):
	velocity = knockback
	move_and_slide()
	if health <= 0:
		self.free()

func _on_area_2d_area_entered(area):
	if area.name == "weapon_area" and Global.attack_ip and can_take_damage:
		can_take_damage = false
		hit(Global.player_damage, (global_position - area.global_position).normalized() * 800)

func hit(damage, knockback_strength):
	knockback = knockback_strength
	var knockback_tween = create_tween()
	var knockback_flash_tween = create_tween()
	knockback_tween.parallel().tween_property(self, "knockback", Vector2.ZERO, .3)
	$enemy_sprite.modulate.v = 15
	knockback_flash_tween.tween_property($enemy_sprite, "modulate:v", 1, .3)
	await knockback_tween.finished
	await knockback_flash_tween.finished
	health -= damage
	can_take_damage = true
