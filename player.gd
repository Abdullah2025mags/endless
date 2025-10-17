extends CharacterBody2D

const GRAVITY: int = 3600
const JUMP_SPEED: int = -1700

var current_anim: String = ""

# Collider base size and offset
const COLLIDER_OFFSET_RUN = Vector2(0, 5)    # RunCol offset 
const COLLIDER_OFFSET_DUCK = Vector2(0, 10)  # DuckCol moved 5px further down to ensure DuckCol is on the floor when ducking
const RUNCOL_NORMAL_HEIGHT = 40 - 20         # 10px from top + 10px from bottom removed because RunCol was to larger
const RUNCOL_JUMP_HEIGHT = 15 - 10           # vertical shrink while jumping

func _physics_process(delta):
	# Apply gravity
	velocity.y += GRAVITY * delta

	# --- COLLIDER POSITION & SIZE ---
	# RunCol (unchanged)
	if has_node("RunCol"):
		$RunCol.position = COLLIDER_OFFSET_RUN
		var run_shape = $RunCol.shape
		if run_shape:
			if is_on_floor():
				run_shape.extents.y = RUNCOL_NORMAL_HEIGHT / 2
			else:
				run_shape.extents.y = RUNCOL_JUMP_HEIGHT / 2

	# DuckCol (moved 5px further down independently)
	if has_node("DuckCol"):
		$DuckCol.position = COLLIDER_OFFSET_DUCK

	# --- PLAYER STATE LOGIC ---
	if is_on_floor():
		if not get_parent().game_running:
			_play_anim("idle")
			_set_collision_state(true, false)
			return

		# Duck takes priority
		if Input.is_action_pressed("ui_down"):
			_play_anim("duck")
			_set_collision_state(false, true)
			return

		# Jump
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_SPEED
			_play_anim("jump")
			_set_collision_state(true, false)
			return

		# Run
		_play_anim("Run")
		_set_collision_state(true, false)

	else:
		# In air → jump
		_play_anim("jump")
		_set_collision_state(true, false)

	move_and_slide()


# Helper: toggle colliders
func _set_collision_state(run: bool, duck: bool):
	if has_node("RunCol"):
		$RunCol.disabled = not run
	if has_node("DuckCol"):
		$DuckCol.disabled = not duck


# Play animation only if different
func _play_anim(anim_name: String):
	if current_anim != anim_name:
		current_anim = anim_name
		$AnimationPlayer.play(anim_name)
