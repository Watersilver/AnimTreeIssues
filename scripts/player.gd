extends CharacterBody2D
class_name PlayerCharacter

@export_range(0.0, 1000.0, 0.1, 'or_greater') var run_speed = 150.0
@export_range(0.0, 1000.0, 0.1, 'or_greater') var jump_impulse = 400.0

@onready var sprite = $Sprite2D
@onready var ap = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var dx = 0
var h_dir = 0

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_impulse
	
	# Get the input direction and handle the movement/deceleration.
	h_dir = Input.get_axis("move_left", "move_right")
	if h_dir:
		velocity.x = h_dir * run_speed
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
	
	dx = position.x
	move_and_slide()
	dx -= position.x
	dx = -dx
	
	handle_anim_tree(delta)

@onready var at = $AnimationTree
var prev_anim = null
var prev_frame = null
var frame_duration = 0
var texture_name_matcher = RegEx.create_from_string('\\/.*')
## In how many steps the animation tree will advance.
## Default is 5 because it is the smallest value that avoids
## both direction change frame lag and later run animation
## first frame small lag (after direction change the first
## frame of run animation lasts for 7 ticks instead of 6)
@export var anim_tree_advance_steps = 5
func handle_anim_tree(delta):
	at.grounded = is_on_floor()
	at.small_v_speed = abs(velocity.y) < 100
	at.descending = velocity.y >= 100
	
	if dx:
		at.running = true
		at.idling = false
	else:
		at.running = false
		at.idling = true
	
	at.changed_facing = false
	if h_dir:
		var prev_r = at.right
		if h_dir > 0:
			at.right = true
			at.left = false
		else:
			at.right = false
			at.left = true
		at.changed_facing = at.right != prev_r
	
	for _i in anim_tree_advance_steps:
		at.advance(delta / anim_tree_advance_steps)
	
	if prev_frame != null and prev_anim and (prev_anim != sprite.texture.resource_path or prev_frame != sprite.frame):
		print(
			# Only print texture name instead of whole path
			texture_name_matcher.search(
				prev_anim
				.replace('res://assets/textures/charTemplate/', '')
				.replace(' 48x48.png', '')
			).get_string().replace('/', ''),
			' | frame: ', prev_frame,
			' | lasted: ', frame_duration
		)
		frame_duration = 0
	prev_anim = sprite.texture.resource_path
	prev_frame = sprite.frame
	frame_duration += 1
