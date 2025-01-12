extends AnimatedSprite2D

# Visual animations
var animations = {
	"idle_no_tail": "idle_no_tail",
	"idle_no_claw": "idle_no_claw",
	"idle_bot_claw": "idle_bot_claw",
	"dash_no_claw": "dash_no_claw",
	"dash_bot_claw": "dash_bot_claw",
	"dash_two_claw": "dash_two_claw",
	"walking_no_tail": "walking_no_tail",
	"walking_no_claw": "walking_no_claw",
	"walking_bot_claw": "walking_bot_claw"
}

#Access to lobster claw state
@onready var lobster_claw_state = $"..".lobster_state
@onready var old_animation = ""
@onready var current_animation = ""


func play_animation(animation_name):
	if animation_name in animations:			
		current_animation = animation_name
		animation = animations[animation_name] 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	lobster_claw_state = str($"..".LOBSTER_STATES.keys()[$"..".lobster_state]).to_lower()

	if Input.is_action_just_pressed("Run"):
		if "dash" not in current_animation:
			old_animation = current_animation
		play_animation('dash_' + lobster_claw_state)
		
	if input_direction != Vector2.ZERO and "dash" not in current_animation:
		play_animation("walking_" + lobster_claw_state)
	elif input_direction == Vector2.ZERO and "dash" not in current_animation:
		play_animation("idle_" + lobster_claw_state)

func _on_animation_looped() -> void:
	if "dash" in current_animation:
		play_animation(old_animation)
