extends Control

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func test_esc():
	if Input.is_action_just_pressed("ui_cancel") and get_tree().paused == false and Global.is_inv_open == false and Global.is_atlas_open == false:
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused and Global.is_inv_open == false and Global.is_atlas_open == false:
		resume()

func _on_resume_btn_pressed():
	resume()

func _on_quit_btn_pressed():
	Global.save_game()
	get_tree().quit()

func _process(delta):
	test_esc()
