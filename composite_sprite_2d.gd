extends Node2D

func body_play(state_name: StringName):
	$Body.play(state_name)
	
func body_part_play(body_part: AnimatedSprite2D, state_name: StringName, state: bool):
	if state:
		body_part.play(state_name)
	else:
		body_part.play("none")
		
func play(animation_name, tail_state, top_state, bot_state, hat_state):
	body_play(animation_name)
	body_part_play($Tail, animation_name, tail_state)
	body_part_play($TopClaw, animation_name, top_state)
	body_part_play($BottomClaw, animation_name, bot_state)
	
	if animation_name == "dash":
		body_part_play($Swoosh, animation_name, true)
	else:
		body_part_play($Swoosh, animation_name, false)
		
	body_part_play($Hat, animation_name, hat_state)

func idling(tail_state, top_state, bot_state, hat_state):
	play("idle", tail_state, top_state, bot_state, hat_state)

func walking(tail_state, top_state, bot_state, hat_state):
	play("walk", tail_state, top_state, bot_state, hat_state)
	
func dashing(tail_state, top_state, bot_state, hat_state):
	play("dash", tail_state, top_state, bot_state, hat_state)

func regrowing(animation_name, tail_state, top_state, bot_state, hat_state):
	body_play(animation_name)
	body_part_play($Tail, animation_name, tail_state)
	
	body_part_play($BottomClaw, animation_name, bot_state)
	
	if animation_name == "dash":
		body_part_play($Swoosh, animation_name, true)
	else:
		body_part_play($Swoosh, animation_name, false)
		
	body_part_play($Hat, animation_name, hat_state)
	
	var growth_total_time = $"../ShootTimer".wait_time
	var growth_current_time = growth_total_time - $"../ShootTimer".time_left
	
	var multiple = int(growth_current_time / growth_total_time * 100)
	
	#5 steps: 0 nothing, 20 first growth, 40 second growth, 60 third growth, 80 last growth
	if multiple < 20:
		$TopClaw.animation = "none"
		$TopClaw.set_frame_and_progress(0,0)
	if multiple >= 20:
		$TopClaw.animation = "grow"
		if multiple >= 20 and multiple < 40:
			$TopClaw.set_frame_and_progress(0,1)
		if multiple >= 40 and multiple < 60:
			$TopClaw.set_frame_and_progress(1,1)
		if multiple >= 60 and multiple < 80:
			$TopClaw.set_frame_and_progress(2,1)
		if multiple >= 80 and multiple < 100:
			$TopClaw.set_frame_and_progress(3,0)
	
