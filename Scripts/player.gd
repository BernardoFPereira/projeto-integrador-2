extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export_range(500.0, 1500.0) var throw_power: float = 800.0

@export var hand_left_position: Vector2
@export var hand_right_position: Vector2

@onready var light_ray: RayCast2D = $LightRay
@onready var hand: Polygon2D = $Hand
@onready var hold_spot: Marker2D = $Hand/HoldSpot

@onready var trajectory_line: Line2D = $TrajectoryLine

@onready var grab_cast_top: RayCast2D = $GrabCastTop
@onready var grab_cast_right: RayCast2D = $GrabCastRight
@onready var grab_cast_left: RayCast2D = $GrabCastLeft
@onready var grab_cast_down: RayCast2D = $GrabCastDown

@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var shadow_collision = $ShadowCollisionShape

@onready var grab_rays = [grab_cast_top, grab_cast_right, grab_cast_left]

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var just_jumped := false

var carried_weapon: Weapon = null
var secondary_weapon: Weapon = null

enum States {
	IDLE,
	WALK,
	DUCT,
	SHADOW_MELD,
	PREP_SHADOW_SHOT,
	SHADOW_SHOT,
	GRAB
}

var last_state: States
var state: States

func _ready():
	set_state(States.IDLE)

func _process(_delta: float) -> void:
	if PlayerManager.is_aiming:
		hand.look_at(get_global_mouse_position())
	
	if PlayerManager.scanning_light:
		var dir_to_light = global_position.distance_to(PlayerManager.light_target.global_position)
		light_ray.enabled = true
		light_ray.target_position.x = dir_to_light
		light_ray.look_at(PlayerManager.light_target.light_pos_marker.global_position)
		light_ray.force_raycast_update()
		
		if light_ray.is_colliding():
			## Debug marker spawn
			#var col_pos = light_ray.get_collision_point()
			#var instance = preload("res://Scenes/collision_marker.tscn").instantiate()
			#instance.global_position = col_pos
			#get_tree().root.add_child(instance)
			
			PlayerManager.set_in_shadow(true)
			#print("In Shadows!")
		else:
			light_ray.enabled = false
			PlayerManager.set_in_shadow(false)
			#print("In Light!")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if state in [States.IDLE, States.WALK, States.SHADOW_SHOT]:
			velocity += get_gravity() * (delta * 2)
		if state in [States.DUCT]:
			velocity = velocity.lerp(Vector2.ZERO, delta)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	handle_states(delta)
	
	move_and_slide()

func handle_states(delta) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	match state:
		States.IDLE:
			if direction:
				set_state(States.WALK)
				
			velocity.x = lerpf(velocity.x, 0, delta * 6)
			
		States.WALK:
			animated_sprite.play("walk")
			if direction:
				velocity.x = lerpf(velocity.x, direction.x * SPEED, delta)
			else:
				set_state(States.IDLE)
			
			if direction.x < 0:
				animated_sprite.flip_h = true

			elif direction.x > 0:
				animated_sprite.flip_h = false
			
		States.DUCT:
			pass
			
		States.SHADOW_MELD:
			if !PlayerManager.is_in_shadow:
				set_state(States.IDLE)
			if direction:
				velocity = velocity.lerp(direction * SPEED, delta)
			else:
				velocity = velocity.lerp(Vector2.ZERO, delta * 4)
			
		States.PREP_SHADOW_SHOT:
			velocity = velocity.lerp(Vector2.ZERO, delta * 6)
			trajectory_line.update_trajectory(global_position.direction_to(get_global_mouse_position()), 100.0, 9.8, delta)
			
		States.SHADOW_SHOT:
			var ground_ray = grab_cast_down
			grab_cast_down.force_raycast_update()
			
			if is_on_floor() and !just_jumped:
				set_state(States.IDLE)
			
			for ray: RayCast2D in grab_rays:
				ray.force_raycast_update()
				var collider = ray.get_collider()
				
				if ray.is_colliding():
					if collider.is_in_group("Grabable") and !just_jumped:
						velocity = Vector2.ZERO
						set_state(States.GRAB)
					else:
						set_state(States.IDLE)
						
			if !ground_ray.is_colliding():
				just_jumped = false
			elif ground_ray.is_colliding():
				just_jumped = true
			
		States.GRAB:
			if direction:
				if grab_cast_left.is_colliding() or grab_cast_right.is_colliding():
					velocity.y = lerp(velocity.y, direction.y * SPEED, delta * 2)
				if grab_cast_top.is_colliding():
					velocity.x = lerpf(velocity.x, direction.x * SPEED, delta * 2)
				
			if !direction:
				velocity = velocity.lerp(Vector2.ZERO, delta * 6)
				
			if !grab_cast_top.is_colliding() and !grab_cast_right.is_colliding() and !grab_cast_left.is_colliding():
				set_state(States.IDLE)

func set_state(new_state: States):
	match new_state:
		States.SHADOW_MELD:
			collision_shape.disabled = true
			shadow_collision.disabled = false
			animated_sprite.play("shadow_shape")
			set_collision_mask_value(5, 0)

		States.SHADOW_SHOT:
			collision_shape.disabled = true
			shadow_collision.disabled = false
			animated_sprite.play("shadow_shape")

		#States.GRAB:
			#collision_shape.disabled = true
			#shadow_collision.disabled = false
			#animated_sprite.play("shadow_shape")
		_:
			collision_shape.disabled = false
			animated_sprite.play("default")
			set_collision_mask_value(5, 1)
			#polygon.polygon = player_base_shape
	
	if new_state != state:
		last_state = state
		state = new_state
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and PlayerManager.can_interact:
		PlayerManager.interact_target.interaction()
	
	if event.is_action_pressed("activate_shadow_meld"):
		#if PlayerManager.is_in_shadow:
		match state:
			States.SHADOW_MELD:
				set_state(States.IDLE)
			_:
				set_state(States.SHADOW_MELD)
	
	if event.is_action_pressed("ui_accept") and state == States.GRAB:
		set_state(States.IDLE)
		
	#if event.is_action_pressed("interact") and VentManager.current_waypoint.is_exit:
		#set_state(States.IDLE)
		
	if event.is_action_pressed("ui_accept") and is_on_floor():
		trajectory_line.visible = true
		#PlayerManager.can_shadowshot = true
		set_state(States.PREP_SHADOW_SHOT)
	
	if event.is_action_released("ui_accept") and is_on_floor():
		trajectory_line.visible = false
		#PlayerManager.can_shadowshot = false
		set_state(States.IDLE)
		
	if event.is_action_pressed("aim"):
		PlayerManager.switch_aim(true)
	if event.is_action_released("aim"):
		hand.rotation_degrees = 40
		PlayerManager.switch_aim(false)
	
	if event.is_action_pressed("shoot") and PlayerManager.is_aiming:
		if carried_weapon:
			match carried_weapon.weapon_type:
				"melee":
					carried_weapon.throw()
				"ranged":
					carried_weapon.shoot()
					pass
				_:
					print("no weapon!")
	
	if event.is_action_pressed("shoot") and (state == States.PREP_SHADOW_SHOT):
		velocity = global_position.direction_to(get_global_mouse_position()) * PlayerManager.shadowshot_speed
		trajectory_line.visible = false
		just_jumped = true
		set_state(States.SHADOW_SHOT)
#
#func _on_grab_area_body_entered(body: Node2D) -> void:
	#if state == States.SHADOW_SHOT:
		#velocity = Vector2.ZERO
		#set_state(States.GRAB)
#
#func _on_grab_area_body_exited(body: Node2D) -> void:
	#if state == States.GRAB:
		#set_state(States.IDLE)
