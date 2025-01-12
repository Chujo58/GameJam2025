extends CharacterBody2D

# Running/moving constants
const DEFAULT_SPEED:int = 200
const RUN_SPEED:int = 200
const DASH_SPEED:int = 400
var SPEED:int = DEFAULT_SPEED
const DASH_REGEN_CD = 1.5
const MAX_DASH_CHARGES = 3

var movement_direction = Vector2.ZERO
var old_movement_direction = Vector2.ZERO
var dash_direction = Vector2.ZERO
var current_dash_charges = 3

@onready var HP = 5
const BULLET = preload("res://Bullet.tscn")
const MELEE_AREA = preload("res://melee_area.tscn")
const GAME_OVER = preload("res://game_over.tscn")

#power-ups
var hasMelee = true
var hasRanged = false
var hasTail = true

var canShoot = true
var dashing = false
# var last_direction
#Sound effects


func get_input(input_dir = Vector2.ZERO):
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	if input_dir != Vector2.ZERO:
		input_direction = input_dir
		
	velocity = input_direction * SPEED
	# last_direction = input_direction

	if velocity != Vector2.ZERO:
		if not $WalkingAudioStream.playing:
			print("walking sound")
			$WalkingAudioStream.play()
		if not dashing:
			if !hasTail:
				$AnimatedSprite2D.play("walking_no_tail")
			if hasTail and not hasMelee and not hasRanged:
				$AnimatedSprite2D.play("walking_no_claw")
			if hasMelee:
				$AnimatedSprite2D.play("walking_bot_claw")
			if hasRanged:
				pass
	else:
		print("idling sound")
		$WalkingAudioStream.stop()
		if not dashing:
			if !hasTail:
				$AnimatedSprite2D.play("idle_no_tail")
			if hasTail and not hasMelee and not hasRanged:
				$AnimatedSprite2D.play("idle_no_claw")
			if hasMelee:
				$AnimatedSprite2D.play("idle_bot_claw")
			if hasRanged:
				pass
				
	return input_direction


func _physics_process(delta: float) -> void:
	movement_direction = get_input(dash_direction)
	if movement_direction != Vector2.ZERO:
		old_movement_direction = movement_direction
	move_and_slide()
	
	if Input.is_action_just_pressed("Run") and hasTail:
		$DashTimer.start()
		SPEED = DASH_SPEED
		velocity = Input.get_vector("Left","Right","Up","Down")*SPEED
		if !hasTail:
			pass
		if hasTail and not hasMelee and not hasRanged:
			$AnimatedSprite2D.play("dash_no_claw")
		if hasMelee:
			$AnimatedSprite2D.play("dash_bot_claw")
		if hasRanged:
			pass
		dashing = true


	$CollisionShape2D/Muzzle.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("Shoot") and hasRanged:
		shoot()
	
	if Input.is_action_just_pressed("Melee"):
		melee()
		hasMelee = true
	
	if get_global_mouse_position().x < position.x:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.offset.x = -3
		$AnimatedSprite2D.offset.y = -2
	else:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.offset.x = 3
		$AnimatedSprite2D.offset.y = -2
		
		
func _on_dash_timer_timeout() -> void:
	SPEED = DEFAULT_SPEED
	dashing = false

func shoot():
	if canShoot:
		var bullet = BULLET.instantiate()
		owner.add_child(bullet)
		bullet.transform = $CollisionShape2D/Muzzle.global_transform
		$ShootTimer.start()
		canShoot = false
	
	
func melee():
	if hasMelee:
		if velocity != Vector2.ZERO:
			$AnimatedSprite2D.play("walking_no_claw")
		else:
			$AnimatedSprite2D.play("idle_no_claw")
		hasMelee = false
		var melee_area = MELEE_AREA.instantiate()
		$CollisionShape2D/Muzzle.add_child(melee_area)
	
	
func take_damage(value:int):
	HP-=value
	$HealthBar/ProgressBar.value = HP
	if HP <= 0:
		var game_over = GAME_OVER.instantiate()
		$"..".add_child(game_over)

func _on_shoot_timer_timeout() -> void:
	canShoot = true


#func _on_walking_audio_stream_finished() -> void:
	#walking_stream.play()
	#pass # Replace with function body.
