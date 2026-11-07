class_name PlayerControl extends Node
@export var root: XROrigin3D
@export var physics: PlayerPhysics
@export var phys_head: RigidBody3D
@export var phys_lhand: RigidBody3D
@export var phys_rhand: RigidBody3D
@export var phys_torso: RigidBody3D
@export var real_lhand: XRController3D
@export var real_rhand: XRController3D
@export var real_head: XRController3D
@export var walking_speed = 500.0

@export var player_attached: Array[CollisionObject3D]
var player_attached_rids: Array[RID]

var grip_timing: float = 0.35
var rhand_grip_time: float = grip_timing
var lhand_grip_time: float = grip_timing

var lhand_grip: SliderJoint3D
var rhand_grip: SliderJoint3D
var old_lgrip: float = 0
var old_rgrip: float = 0
var grip_threshold: float = 0.1

var override_grip = false

func weld(grip: SliderJoint3D,other: PhysicsBody3D):
	if grip == lhand_grip and other:
		grip.global_transform = phys_lhand.global_transform
		grip.node_a = phys_lhand.get_path()
		grip.node_b = other.get_path()
	elif grip == rhand_grip and other:
		grip.global_transform = phys_rhand.global_transform
		grip.node_a = phys_rhand.get_path()
		grip.node_b = other.get_path()
	else:
		grip.node_a = NodePath()
		grip.node_b = NodePath()
		

func float_lhand(name: String,value: float):
	if not lhand_grip.node_b.is_empty() and name == "trigger":
		var obj = get_node(lhand_grip.node_b)
		obj.change_trigger(phys_lhand,value)

func float_rhand(name: String,value: float):
	if not rhand_grip.node_b.is_empty() and name == "trigger":
		var obj = get_node(rhand_grip.node_b)
		obj.change_trigger(phys_rhand,value)
		
func press_lhand(name: String):
	if not lhand_grip.node_b.is_empty() and name == "primary":
		var obj = get_node(lhand_grip.node_b)
		obj.on_primary_interaction(phys_lhand,true)
	if not lhand_grip.node_b.is_empty() and name == "secondary":
		var obj = get_node(lhand_grip.node_b)
		obj.on_secondary_interaction(phys_lhand,true)

func press_rhand(name: String):
	if not rhand_grip.node_b.is_empty() and name == "primary":
		var obj = get_node(rhand_grip.node_b)
		obj.on_primary_interaction(phys_rhand,true)
	if not rhand_grip.node_b.is_empty() and name == "secondary":
		var obj = get_node(rhand_grip.node_b)
		obj.on_secondary_interaction(phys_rhand,true)

func release_lhand(name: String):
	if not lhand_grip.node_b.is_empty() and name == "primary":
		var obj = get_node(lhand_grip.node_b)
		obj.on_primary_interaction(phys_lhand,false)
	if not lhand_grip.node_b.is_empty() and name == "secondary":
		var obj = get_node(lhand_grip.node_b)
		obj.on_secondary_interaction(phys_lhand,false)

func release_rhand(name: String):
	if not rhand_grip.node_b.is_empty() and name == "primary":
		var obj = get_node(rhand_grip.node_b)
		obj.on_primary_interaction(phys_rhand,false)
	if not rhand_grip.node_b.is_empty() and name == "secondary":
		var obj = get_node(rhand_grip.node_b)
		obj.on_secondary_interaction(phys_rhand,false)


func attempt_to_stand():
	var rotation = phys_torso.global_basis.get_euler(EULER_ORDER_YXZ)
	if abs(rotation.x) < 10 and abs(rotation.z) < 10 and phys_torso.linear_velocity.length() < 0.2 and phys_torso.angular_velocity.length() < 0.2:
		physics.standing = true

func _ready():
	var array: Array[RID] = []
	for obj in player_attached:
		array.push_back(obj.get_rid())
	real_lhand.input_float_changed.connect(float_lhand)
	real_rhand.input_float_changed.connect(float_rhand)
	real_lhand.button_pressed.connect(press_lhand)
	real_rhand.button_pressed.connect(press_rhand)
	real_lhand.button_released.connect(release_lhand)
	real_rhand.button_released.connect(release_rhand)
	phys_lhand.contact_monitor = true
	phys_rhand.contact_monitor = true
	phys_lhand.max_contacts_reported = 3
	phys_rhand.max_contacts_reported = 3
	lhand_grip = SliderJoint3D.new()
	rhand_grip = SliderJoint3D.new()
	lhand_grip.set("linear_limit/lower_distance",0)
	lhand_grip.set("linear_limit/upper_distance",0)
	rhand_grip.set("linear_limit/lower_distance",0)
	rhand_grip.set("linear_limit/upper_distance",0)
	add_child(lhand_grip)
	add_child(rhand_grip)

func root_to_camera(camera_t: Transform3D):
	camera_t = Transform3D(camera_t)
	var root_t = TransformMath.to_local(root.global_transform,real_head.global_transform)
	return TransformMath.to_global(root_t,camera_t)

func get_movements():
	var movement: Vector2 = real_lhand.get_vector2("movement")
	var rotation: Vector2 = real_rhand.get_vector2("rotation")
	var movementb: Vector2 = real_rhand.get_vector2("movement")
	var rotationb: Vector2 = real_lhand.get_vector2("rotation")
	return [(movement+movementb).normalized(), (rotation+rotationb).normalized()]

func _process(delta: float):
	
	# grips
	lhand_grip_time = max(lhand_grip_time-delta,0)
	rhand_grip_time = max(rhand_grip_time-delta,0)
	# position root
	var head_position: Transform3D = Transform3D(physics.real_to_torso_space(real_head.global_transform).basis,phys_head.global_position)
	root.global_transform = root_to_camera(head_position)
	
	var lgrip = real_lhand.get_float("grip")
	var rgrip = real_rhand.get_float("grip")
	if lgrip >= grip_threshold and old_lgrip < grip_threshold:
		lhand_grip_time = grip_timing
	if rgrip >= grip_threshold and old_rgrip < grip_threshold:
		rhand_grip_time = grip_timing
	if (lgrip >= grip_threshold and lhand_grip_time > 0) or override_grip:
		#get_viewport().use_xr = true
		#print("trying grab l")
		var bodies = phys_lhand.get_colliding_bodies()
		for body in bodies:
			if body.has_method("on_grab"):
				weld(lhand_grip,body)
				body.on_grab(phys_lhand)
				physics.lhand_strength_alpha = body.get_strength()
				break
	if (rgrip >= grip_threshold and rhand_grip_time > 0) or override_grip:
		#print("trying grab r")
		var bodies = phys_rhand.get_colliding_bodies()
		for body in bodies:
			print("rhand touching")
			if body.has_method("on_grab"):
				weld(rhand_grip,body)
				body.on_grab(phys_rhand)
				physics.rhand_strength_alpha = body.get_strength()
				break
	if lgrip < grip_threshold and not override_grip:
		if not lhand_grip.node_b.is_empty():
			var node = get_node(lhand_grip.node_b)
			if node:
				node.on_release(phys_lhand)
		weld(lhand_grip,null)
		physics.lhand_strength_alpha = 0
	if rgrip < grip_threshold and not override_grip:
		if not rhand_grip.node_b.is_empty():
			var node = get_node(rhand_grip.node_b)
			if node:
				node.on_release(phys_rhand)
		weld(rhand_grip,null)
		physics.rhand_strength_alpha = 0
		
	old_lgrip = real_lhand.get_float("grip")
	old_rgrip = real_rhand.get_float("grip")
	
	# movement
	var movements = get_movements()
	var movement = movements[0]
	var rotation = movements[1]
	
	if physics.standing:
		var movement_vector = physics.desired_torso.global_basis.z * -movement.x + physics.desired_torso.global_basis.x * -movement.y
		var movement_impulse = delta*movement_vector*walking_speed
		phys_torso.apply_impulse(movement_impulse)
	if abs(rotation.y)<0.3:
		physics.player_rotation += rotation.x * delta * 1.2 
	if rotation.y > 0.6:
		attempt_to_stand()
	if rotation.y < -0.6:
		physics.standing = false
	
func _physics_process(delta: float) -> void:
	root.set_deferred("global_transform",Transform3D(Basis.IDENTITY,Vector3.ZERO))
