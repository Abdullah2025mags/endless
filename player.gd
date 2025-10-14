extends CharacterBody2D

const GRAVITY: int = 3600
const JUMP_SPEED: int = -1700

var current_anim: String = ""

func _physics_process(delta):
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Check if the player is on the ground
	if is_on_floor():
		if not get_parent().game_running:
			# Game not started yet → idle animation
			_play_anim("idle")
		else:
			$RunCol.disabled = false

			if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up"):
				# Jump
				velocity.y = JUMP_SPEED
				_play_anim("jump")

			elif Input.is_action_pressed("ui_down"):
				# Duck
				_play_anim("duck")
				$RunCol.disabled = true

			else:
				# Run normally
				_play_anim("Run")
	else:
		# In the air
		_play_anim("jump")

	move_and_slide()


# Only change animation if it's different
func _play_anim(anim_name: String):
	if current_anim != anim_name:
		current_anim = anim_name
		$AnimationPlayer.play(anim_name)
