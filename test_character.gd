extends CharacterBody2D

const DEFAULT_SPEED = 300.0
const RUN_SPEED = 450.0
const DASH_SPEED = 1800.0
@onready var SPEED = DEFAULT_SPEED

const DOUBLETAP_DELAY = .25
const DASH_DELAY = 1
var doubletap_time = DOUBLETAP_DELAY
var dash_time = DASH_DELAY
var last_keycode = 0

func get_input():
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	velocity = input_direction*SPEED


func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	
	if Input.is_action_just_pressed("Run"):
		$DashTimer.start()
		SPEED = DASH_SPEED
		velocity = Input.get_vector("Left","Right","Up","Down")*SPEED
		

func _on_dash_timer_timeout() -> void:
	SPEED = DEFAULT_SPEED
