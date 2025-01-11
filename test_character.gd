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

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if last_keycode == event.keycode and doubletap_time > 0 and dash_time > 0:
			if String.chr(last_keycode) == 'R':
				SPEED = DASH_SPEED
			last_keycode = 0
		else:
			last_keycode = event.keycode
			if dash_time < 0:
				SPEED = RUN_SPEED
			
		doubletap_time = DOUBLETAP_DELAY
		
	if event.is_action_released("Run"):
		SPEED = DEFAULT_SPEED



func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

	doubletap_time -= delta
	dash_time -= delta

	if Input.is_action_pressed("Run"):
		SPEED = RUN_SPEED
