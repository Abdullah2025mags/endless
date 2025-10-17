extends Node2D

# --- Preload obstacles ---
var saw_scene = preload("res://saw.tscn")
var barrel1_scene = preload("res://barrel1.tscn")
var barrel2_scene = preload("res://barrel2.tscn")
var bird_scene = preload("res://bird.tscn")
var obstacle_types := [barrel2_scene, barrel1_scene, saw_scene]
var obstacles : Array
var bird_heights := [200, 390]

# --- Game variables ---
const player_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# --- Called when the node enters the scene tree ---
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	
	# Connect the Button inside GameOver
	$GameOver.get_node("Button").pressed.connect(new_game)
	
	obstacles = []
	new_game()

# --- Reset/start game ---
func new_game():
	# Reset variables
	score = 0
	show_score()
	game_running = false
	difficulty = 0

	# Delete all obstacles
	if obstacles:
		for obs in obstacles:
			obs.queue_free()
	obstacles = []

	# Reset player, camera, ground
	$player.position = player_START_POS
	$player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

	# Reset HUD and GameOver
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

# --- Called every frame ---
func _process(delta):
	if game_running:
		# Speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		# Generate obstacles
		generate_obs()
		
		# Move player and camera
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		# Update score
		score += speed
		show_score()
		
		# Update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		# Remove obstacles off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		# Start game from StartLabel or restart after GameOver
		if Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN):
			if $GameOver.visible:
				new_game()  # Restart after GameOver
			else:
				game_running = true
				$HUD.get_node("StartLabel").hide()

# --- Obstacle generation ---
func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_scale = obs.get_child(0).scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (64 * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		# Chance to spawn birds at max difficulty
		if difficulty == MAX_DIFFICULTY and (randi() % 2) == 0:
			obs = bird_scene.instantiate()
			var obs_x : int = screen_size.x + score + 100
			var obs_y : int = bird_heights[randi() % bird_heights.size()]
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "player":
		game_over()

# --- Score & HUD ---
func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

# --- Game over ---
func game_over():
	check_high_score()
	game_running = false
	$GameOver.show()
