extends CharacterBody2D

# Running/moving constants
const DEFAULT_SPEED:int = 200
const RUN_SPEED:int = 200
const DASH_SPEED:int = 400
var SPEED:int = DEFAULT_SPEED

@onready var HP = 5
const BULLET = preload("res://Bullet.tscn")
const MELEE_AREA = preload("res://melee_area.tscn")
const GAME_OVER = preload("res://game_over.tscn")

#power-ups
var hasMelee = false
var hasRanged = false
var hasTail = false

var canShoot = true
var dashing = false
# var last_direction
#Sound effects
@onready var walking_stream = $WalkingAudioStream

func get_input() -> void:
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	velocity = input_direction*SPEED
	# last_direction = input_direction

	if velocity != Vector2.ZERO:
		if not walking_stream.playing:
			walking_stream.play()
		if not dashing:
			$AnimatedSprite2D.play("mouvement")
	else:
		walking_stream.stop()
		if not dashing:
			$AnimatedSprite2D.play("idle")


func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	
	if Input.is_action_just_pressed("Run") and hasTail:
		$DashTimer.start()
		SPEED = DASH_SPEED
		velocity = Input.get_vector("Left","Right","Up","Down")*SPEED
		$AnimatedSprite2D.play("dash_no_claw")
		dashing = true


	$CollisionShape2D/Muzzle.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("Shoot") and hasRanged:
		shoot()
	
	if Input.is_action_just_pressed("Melee"):
		melee()
	
	
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
