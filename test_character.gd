extends CharacterBody2D

# Running/moving constants
const DEFAULT_SPEED:int = 200
const RUN_SPEED:int = 200
const DASH_SPEED:int = 400
var SPEED:int = DEFAULT_SPEED

const MAX_DASH_CHARGES = 3
const MAX_HP = 750

#Variables for motion
var movement_direction = Vector2.ZERO
var old_movement_direction = Vector2.ZERO
var dash_direction = Vector2.ZERO
var current_dash_charges = 3

var dashing = false
var walking = false

@onready var HP = MAX_HP
const BULLET = preload("res://Bullet.tscn")
const MELEE_AREA = preload("res://melee_area.tscn")
const GAME_OVER = preload("res://game_over.tscn")

#power-ups
var hasMelee = false
var hasRanged = false
var hasTail = false
var hasHat = false

#State of attack:
var doingMeleeAtk = false
var doingRangedAtk = false

var melee_area = null
var bullet = null

#Variable for lobster attack options
var clearcount = 0
var canShoot = true
var isInSpawn = true

var isGameOver = true
var hasDied = false

#Variable for sound
@onready var audio_streams = [$WalkingAudioStream, $DashingAudioStream, $TakingDamageAudioStream, $DeathByAcid, $DeathByHit, $MeleeMissAtk, $MeleeAtk, $RangedAtk]
var muted = false

func _ready():
	$DashBar/ProgressBar.max_value = MAX_DASH_CHARGES
	$DashBar/ProgressBar.value = current_dash_charges
	$HealthBar/ProgressBar.max_value = MAX_HP
	$"../MainTheme".play()

func mute():
	for node in audio_streams:
		node.stop()
		node.playing = false

func play_animation():
	if doingMeleeAtk:
		hasMelee = false
	if doingRangedAtk:
		hasRanged = false

	if not walking and not dashing:
		$CompositeSprite2D.idling(hasTail, hasRanged, hasMelee, hasHat)
	if walking:
		$CompositeSprite2D.walking(hasTail, hasRanged, hasMelee, hasHat)
	if dashing:
		$CompositeSprite2D.dashing(hasTail, hasRanged, hasMelee, hasHat)


func get_input(input_dir = Vector2.ZERO):
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	if input_dir != Vector2.ZERO:
		input_direction = input_dir
		
	velocity = input_direction * SPEED
	# last_direction = input_direction

	if walking: #If the character is moving around
		if dashing:
			if $WalkingAudioStream.playing:
				$WalkingAudioStream.stop()
			$DashingAudioStream.play()
			
		if not $WalkingAudioStream.playing:
			$WalkingAudioStream.play()
	else:
		$WalkingAudioStream.stop()
				
	return input_direction


func _physics_process(delta: float) -> void:
	movement_direction = get_input(dash_direction)
	if movement_direction != Vector2.ZERO:
		old_movement_direction = movement_direction
		walking = true
	else:
		walking = false
	
	if not isGameOver:
		move_and_slide()
		
	doingMeleeAtk = false
	
	if Input.is_action_just_pressed("Run") and hasTail and current_dash_charges > 0 and not isGameOver:
		$DashTimer.start()
		SPEED = DASH_SPEED
		
		$DashRegenCD.start()
		current_dash_charges -= 1
		
		if movement_direction != Vector2.ZERO:
			velocity = Input.get_vector("Left","Right","Up","Down") * SPEED
		else:
			dash_direction = old_movement_direction
			velocity = old_movement_direction * SPEED
			
		dashing = true
		
	$DashBar/ProgressBar.value = current_dash_charges - round($DashRegenCD.time_left/$DashRegenCD.wait_time * 100)/100 + 1

	$CollisionShape2D/Muzzle.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("Shoot") and hasRanged and not isGameOver:
		doingRangedAtk = true
		shoot()
	
	if Input.is_action_just_pressed("Melee") and not isGameOver and hasMelee:
		doingMeleeAtk = true
		melee()
	
	if get_global_mouse_position().x < position.x:
		$CompositeSprite2D.scale.x = 1
		if melee_area != null:
			melee_area.scale.y = -1
	else:
		$CompositeSprite2D.scale.x = -1
		if melee_area != null:
			melee_area.scale.y = 1

	if doingRangedAtk:
		if dashing: $CompositeSprite2D.regrowing("dash", hasTail, hasRanged, hasMelee, hasHat)
		if walking: $CompositeSprite2D.regrowing("walk", hasTail, hasRanged, hasMelee, hasHat)
		if not dashing and not walking: $CompositeSprite2D.regrowing("idle", hasTail, hasRanged, hasMelee, hasHat)
	else:
		play_animation()

	if muted:
		mute()
		

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
		bullet = BULLET.instantiate()
		owner.add_child(bullet)
		bullet.transform = $CollisionShape2D/Muzzle.global_transform
		$ShootTimer.start()
		canShoot = false
	
	
func melee():
	if hasMelee:
		$MeleeMissAtk.play()
		melee_area = MELEE_AREA.instantiate()
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
		isGameOver = true
		$"..".add_child(game_over)

func _on_shoot_timer_timeout() -> void:
	canShoot = true
	hasRanged = true
	doingRangedAtk = false
