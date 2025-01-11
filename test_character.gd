extends CharacterBody2D

# Running/moving constants
const DEFAULT_SPEED = 300.0
const RUN_SPEED = 450.0
const DASH_SPEED = 10000.0
@onready var SPEED = DEFAULT_SPEED

# Dash with double tapping the 'R' key
const DOUBLETAP_DELAY = .25
const DASH_CD = 5
const DASH_DELAY = 1
@onready var doubletap_time = DOUBLETAP_DELAY
@onready var dash_time = DASH_DELAY
@onready var dash_timer_cd = Timer.new()
@onready var last_keycode = 0

func get_input():
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	velocity = input_direction*SPEED

func _input(event):
	if event is InputEventKey:
		if last_keycode == event.keycode and doubletap_time > 0 and dash_time > 0 and dash_timer_cd.time_left <= 0:
			if String.chr(last_keycode) == 'R':
				SPEED = DASH_SPEED
			last_keycode = 0
		else:
			last_keycode = event.keycode
			if dash_time < 0:
				SPEED = DEFAULT_SPEED
			
		doubletap_time = DOUBLETAP_DELAY
		dash_timer_cd.start(DASH_CD)
		
	#if event.is_action_released("Run"):
		#SPEED = DEFAULT_SPEED



func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

	doubletap_time -= delta
	dash_time -= delta
