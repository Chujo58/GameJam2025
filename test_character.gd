extends CharacterBody2D

# Running/moving constants
const DEFAULT_SPEED:int = 300
const RUN_SPEED:int = 450
const DASH_SPEED:int = -1200
var SPEED:int = DEFAULT_SPEED

@onready var HP = 5
const BULLET = preload("res://Bullet.tscn")
const MELEE_AREA = preload("res://melee_area.tscn")

const CLAW_STATES = ["NO_CLAW", "ONE_CLAW", "TWO_CLAW"]

@onready var claw_state = CLAW_STATES[0]

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
		# play_animation("mouvement")
	else:
		walking_stream.stop()
		# play_animation("idle")


func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	
	if Input.is_action_just_pressed("Run"):
		$DashTimer.start()
		SPEED = DASH_SPEED
		velocity = Input.get_vector("Left","Right","Up","Down")*SPEED
		# velocity = last_direction * SPEED
	
	$CollisionShape2D.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("Shoot"):
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
		$AnimatedSprite2D.offset.y = 0

func _on_dash_timer_timeout() -> void:
	SPEED = DEFAULT_SPEED

func shoot():
	var bullet = BULLET.instantiate()
	owner.add_child(bullet)
	bullet.transform = $CollisionShape2D/Muzzle.global_transform
	
	
func melee():
	var melee_area = MELEE_AREA.instantiate()
	$CollisionShape2D.add_child(melee_area)
