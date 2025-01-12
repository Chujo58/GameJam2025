extends CharacterBody2D

# Running/moving constants
const DEFAULT_SPEED:int = 200
const RUN_SPEED:int = 200
const DASH_SPEED:int = 400
var SPEED:int = DEFAULT_SPEED

const MAX_DASH_CHARGES = 3
const MAX_HP = 100

var movement_direction = Vector2.ZERO
var old_movement_direction = Vector2.ZERO
var dash_direction = Vector2.ZERO
var current_dash_charges = 3

@onready var HP = MAX_HP
const BULLET = preload("res://Bullet.tscn")
const MELEE_AREA = preload("res://melee_area.tscn")
const GAME_OVER = preload("res://game_over.tscn")

#power-ups
var hasMelee = true
var hasRanged = true
var hasTail = true

var canShoot = true
var dashing = false

var hasDied = false

func _ready():
	$DashBar/ProgressBar.max_value = MAX_DASH_CHARGES
	$DashBar/ProgressBar.value = current_dash_charges

func get_input(input_dir = Vector2.ZERO):
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	if input_dir != Vector2.ZERO:
		input_direction = input_dir
		
	velocity = input_direction * SPEED
	# last_direction = input_direction

	if velocity != Vector2.ZERO:
		if dashing:
			if $WalkingAudioStream.playing:
				$WalkingAudioStream.stop()
			$DashingAudioStream.play()
			
		if not $WalkingAudioStream.playing:
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
	
	if Input.is_action_just_pressed("Run") and hasTail and current_dash_charges > 0:
		$DashTimer.start()
		SPEED = DASH_SPEED
		
		$DashRegenCD.start()
		current_dash_charges -= 1
		
		if movement_direction != Vector2.ZERO:
			velocity = Input.get_vector("Left","Right","Up","Down") * SPEED
		else:
			dash_direction = old_movement_direction
			velocity = old_movement_direction * SPEED
			
		if !hasTail:
			pass
		if hasTail and not hasMelee and not hasRanged:
			$AnimatedSprite2D.play("dash_no_claw")
		if hasMelee:
			$AnimatedSprite2D.play("dash_bot_claw")
		if hasRanged:
			pass
		dashing = true
		
	$DashBar/ProgressBar.value = current_dash_charges - round($DashRegenCD.time_left/$DashRegenCD.wait_time * 100)/100 + 1

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
		
		

func _on_dash_regen_cd_timeout() -> void:
	if current_dash_charges < MAX_DASH_CHARGES:
		current_dash_charges += 1
		$DashBar/ProgressBar.value = current_dash_charges
		$DashRegenCD.start()
	else:
		$DashRegenCD.stop()

func _on_dash_timer_timeout() -> void:
	SPEED = DEFAULT_SPEED
	dashing = false
	dash_direction = Vector2.ZERO

func shoot():
	if canShoot:
		$RangedAtk.play()
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
		$MeleeMissAtk.play()
		var melee_area = MELEE_AREA.instantiate()
		$CollisionShape2D/Muzzle.add_child(melee_area)
	
	
func take_damage(value:int):
	if HP > 0:
		HP-=value
		$HealthBar/ProgressBar.value = HP
		$TakingDamageAudioStream.play()
		
	if HP <= 0 and !hasDied:
		hasDied = true
		$DeathByHit.play()
		var game_over = GAME_OVER.instantiate()
		$"..".add_child(game_over)

func _on_shoot_timer_timeout() -> void:
	canShoot = true
