extends AnimatedSprite2D

# Visual animations
var animations = {
	"idle": "idle",
	"dash_no_claw":"dash_no_claw",
	"dash_one_claw":"dash_one_claw",
	"dash_two_claw":"dash_two_claw",
	"mouvement":"mouvement"
}

#Access to lobster claw state
@onready var lobster_claw_state = $"..".claw_state
@onready var old_animation = ""
@onready var current_animation = ""
@onready var animator = $"."

func play_animation(animation_name):
	if animation_name in animations:			
		current_animation = animation_name
		animation = animations[animation_name] 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	if Input.is_action_just_pressed("Run"):
		lobster_claw_state = $"..".claw_state
		old_animation = current_animation
		play_animation('dash_'+str(lobster_claw_state).to_lower())
		
	#print(input_direction)
	if input_direction != Vector2.ZERO and "dash" not in current_animation:
		play_animation("mouvement")
		
	elif input_direction == Vector2.ZERO and "dash" not in current_animation:
		play_animation("idle")
	#if "dash" not in current_animation:
		#play_animation("idle")



func _on_animation_looped() -> void:
	if "dash" in current_animation:
		print(old_animation)
		play_animation(old_animation)
