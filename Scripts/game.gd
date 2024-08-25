extends Node2D

@export var enemy_scenes: Array[PackedScene] = []

@onready var player_spawn_pos = $PlayerSpawn
@onready var laser_container = $LaserContainer
@onready var timer = $EnemySpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var hud = $UILayer/HUD
@onready var game_over_screen = $UILayer/GameOverScreen
@onready var parallax_background = $ParallaxBackground
@onready var laser_sound = $SFX/LaserSound
@onready var hit_sound = $SFX/HitSound
@onready var explode_sound = $SFX/ExplodeSound

var player = null
var score := 0:
	set(value):
		score = value
		hud.score = score
var high_score

var scroll_speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	var saved_file = FileAccess.open("user://save.data", FileAccess.READ)
	if saved_file != null:
		high_score = saved_file.get_32()
	else:
		high_score = 0
		save_game()

	score = 0
	player = get_tree().get_first_node_in_group("player")
	assert(player != null)
	player.global_position = player_spawn_pos.global_position
	player.laser_shot.connect(_on_player_laser_shot)
	player.killed.connect(_on_player_killed)
	
func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
	if timer.wait_time > 0.5:
		timer.wait_time -= delta * 0.005
	elif timer.wait_time < 0.5:
		timer.wait_time = 0.5
		
	parallax_background.scroll_offset.y += delta * scroll_speed
	if(parallax_background.scroll_offset.y >= 960):
		parallax_background.scroll_offset.y = 0

func _on_player_laser_shot(laser_scene, laser_location):
	var laser = laser_scene.instantiate()
	laser.global_position = laser_location
	laser_container.add_child(laser)
	laser_sound.play()

func _on_enemy_spawn_timer_timeout():
	var enemy = enemy_scenes.pick_random().instantiate()
	enemy.global_position = Vector2(randf_range(50, 500), 0)
	enemy.killed.connect(_on_enemy_killed)
	enemy.hit.connect(_on_enemy_hit)
	enemy_container.add_child(enemy)
	
func _on_enemy_killed(points):
	hit_sound.play()
	score += points
	if(score > high_score):
		high_score = score
	
func _on_enemy_hit():
	hit_sound.play()

func _on_player_killed():
	explode_sound.play()
	game_over_screen.set_score(score)
	game_over_screen.set_high_score(high_score)
	save_game()
	await get_tree().create_timer(1.5).timeout
	game_over_screen.visible = true
	
