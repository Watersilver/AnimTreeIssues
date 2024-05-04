extends CharacterBody2D

@onready var label = $Node2D/Label

const SPEED = 100.0
const JUMP_VELOCITY = -350.0

var start_pos
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var use_fix = false

func _ready():
	start_pos = position

func _physics_process(delta):
	var h_dir = Input.get_axis("ui_left", "ui_right")
	if h_dir:
		velocity.x = h_dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if motion_mode == MOTION_MODE_GROUNDED:
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if Input.is_action_just_pressed("ui_select") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	if motion_mode == MOTION_MODE_FLOATING:
		var v_dir = Input.get_axis("ui_up", "ui_down")
		if v_dir:
			velocity.y = v_dir * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if use_fix:
		move(delta)
	else:
		move_and_slide()
	queue_redraw()
	
	label.text = "My speed is: " + str(ceil(velocity.length()))
	
	if motion_mode == MOTION_MODE_GROUNDED:
		label.text += "\nis_on_floor: " + str(is_on_floor())

func _draw():
	draw_line(Vector2.ZERO, Vector2.ZERO + velocity, Color.ROYAL_BLUE, 2)
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
			#safe_margin
			#print(collision.get_depth())
			#print(collision.get_travel())
			#print(collision.get_remainder())
		var start = c.get_position() - global_position
		var end = start + c.get_normal() * 10
		draw_line(start, end, Color.BROWN, 1)
		draw_circle(start, 1, Color.BROWN)


func move(delta: float):
	var prev_velocity = velocity
	move_and_slide()
	
	# Fix corner bug
	var col = get_last_slide_collision()
	# Check if velocity and collision are perpendicular...
	if col and not col.get_normal().dot(prev_velocity):
		# If they are and collision stopped movement instead of sliding...
		if col.get_remainder().length():
			# Move to location where it can slide
			velocity = col.get_normal() * safe_margin
			move_and_slide()
			velocity = prev_velocity
			move(delta)

func _on_center_pressed():
	position = start_pos
	velocity = Vector2(0, 0)

func _on_mode_selected(index):
	if index == 0:
		motion_mode = MOTION_MODE_FLOATING
	else:
		motion_mode = MOTION_MODE_GROUNDED


func _on_fix_toggled(toggled_on):
	use_fix = toggled_on
