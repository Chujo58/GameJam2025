extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../../test_character".muted = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(sprite_frames.get_frame_count("default"))
	$"../../test_character".mute()
	pass

func _input(event):
	if event.is_action_pressed("Click"):
		if frame < sprite_frames.get_frame_count("default") - 1:
			frame += 1
		else:
			frame = 4  #Stay on last frame

	
