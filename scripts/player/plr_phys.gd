class_name PlayerPhysics extends Node

@export var left_hand: Node3D
@export var right_hand: Node3D
@export var head: Node3D
@export var real_origin: Node3D
@export var neck_pin: PinJoint3D

@export var phys_lhand: PhysicsBody3D
@export var phys_rhand: PhysicsBody3D
@export var phys_head: PhysicsBody3D
@export var phys_torso: PhysicsBody3D # invisible torso used as a mass

@export var lhand_constraint: Generic6DOFJoint3D
@export var rhand_constraint: Generic6DOFJoint3D
@export var neck_constraint: Generic6DOFJoint3D # you still gotta have a neck joint
@export var upright_constraint: Generic6DOFJoint3D # legs
@export var torso_rotation_constraint: Generic6DOFJoint3D
var desired_torso: RigidBody3D
var desired_upright: StaticBody3D

@export var curr_desired_lhand: RigidBody3D
@export var curr_desired_rhand: RigidBody3D

@export var control: PlayerControl
 
#var reaction_force: bool = true

var neck_body: StaticBody3D

@export var hand_strength: float = 300.0
@export var hand_rot_strength: float = 5.0
@export var hand_damping: float = 200.0
@export var hand_rot_damping: float = 0.5
@export var dist_head_neck: float = 0.175
@export var dist_torso_neck: float = 0.175

@export var max_strength_multi: float = 2
@export var max_rot_strength_multi: float = 1.6

@export var lhand_strength_alpha: float = 0
@export var rhand_strength_alpha: float = 0

@export var neck_strength: float = 100.0
@export var neck_damping: float = 50.0

@export var torso_strength: float = 300.0
@export var torso_damping: float = 25.0

@export var upright_strength: float = 800.0
@export var upright_damping: float = 75.0

@export var standing = false

@export var standing_strength: float = 3000.0
@export var standing_damping: float = 100.0
@export var true_standing_damping: float = 900.0
@export var standing_constraint: Generic6DOFJoint3D
var desired_standing: ForceHolder

@export var extra_standing_length = 0.1

var player_rotation = 0



func update_constraints():
	lhand_constraint.global_transform = phys_lhand.global_transform
	rhand_constraint.global_transform = phys_rhand.global_transform
	curr_desired_lhand.global_transform = phys_lhand.global_transform
	curr_desired_rhand.global_transform = phys_rhand.global_transform
	lhand_constraint.node_a = curr_desired_lhand.get_path()
	rhand_constraint.node_a = curr_desired_rhand.get_path()
	lhand_constraint.node_b = phys_lhand.get_path()
	rhand_constraint.node_b = phys_rhand.get_path()
	
func update_strength():
	Constraints.change_constraint(lhand_constraint,true)
	Constraints.change_constraint(rhand_constraint,true)
	var lhand_strength = hand_strength*(1-lhand_strength_alpha) + hand_strength*max_strength_multi*lhand_strength_alpha
	var rhand_strength = hand_strength*(1-rhand_strength_alpha) + hand_strength*max_strength_multi*rhand_strength_alpha
	var lhand_rot_strength = hand_rot_strength*(1-lhand_strength_alpha) + hand_rot_strength*max_rot_strength_multi*lhand_strength_alpha
	var rhand_rot_strength = hand_rot_strength*(1-rhand_strength_alpha) + hand_rot_strength*max_rot_strength_multi*rhand_strength_alpha
	var lhand_damping = hand_damping*(1-lhand_strength_alpha) + hand_damping*max_rot_strength_multi*lhand_strength_alpha
	var rhand_damping = hand_damping*(1-rhand_strength_alpha) + hand_damping*max_rot_strength_multi*rhand_strength_alpha
	var lhand_rot_damping = hand_rot_damping*(1-lhand_strength_alpha) + hand_rot_damping*max_rot_strength_multi*lhand_strength_alpha
	var rhand_rot_damping = hand_rot_damping*(1-rhand_strength_alpha) + hand_rot_damping*max_rot_strength_multi*rhand_strength_alpha


	Constraints.change_strength(lhand_constraint,lhand_strength,lhand_damping,lhand_rot_strength,lhand_rot_damping)
	Constraints.change_strength(rhand_constraint,rhand_strength,rhand_damping,rhand_rot_strength,rhand_rot_damping)
	Constraints.change_strength(torso_rotation_constraint,0,0,torso_strength,torso_damping)

func stand(delta: float):
	if standing:
		var height: float = head.position.y - head.basis.y.y*dist_head_neck - dist_torso_neck
		var space_state = head.get_world_3d().direct_space_state
		# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters3D.create(phys_torso.global_position, phys_torso.global_position + Vector3(0,-height-extra_standing_length,0))
		query.exclude = control.player_attached_rids
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			standing = false
		else:
			desired_standing.global_position = result.position + Vector3(0,height,0) + Vector3(0,(0.87-0.789),0) # offset height for whatever
			desired_standing.rotation = Vector3.ZERO
			#print(height)
			var forces = desired_standing.forces
			desired_standing.forces = Vector3(0,0,0)
			var second_force = -phys_torso.linear_velocity * phys_torso.mass * (1/pow(true_standing_damping,delta))
			forces -= second_force
			phys_torso.apply_impulse(second_force)
			phys_torso.apply_torque_impulse(-phys_torso.angular_velocity * phys_torso.mass * (1/pow(true_standing_damping,delta)))
			var result_owner = result.collider.owner
			if result_owner and result_owner is RigidBody3D:
				result_owner.apply_impulse(forces,result.position-result_owner.global_position)
	
	Constraints.change_constraint_rot(upright_constraint,standing)
	Constraints.change_constraint(standing_constraint,standing)
	upright_constraint.set("angular_spring_y/enabled",false)
	standing_constraint.set("linear_spring_x/enabled",false)
	standing_constraint.set("linear_spring_z/enabled",false)

func get_real_torso_position():
	var real_torso_t = Transform3D(real_origin.transform)
	real_torso_t = real_torso_t.translated(-real_torso_t.origin)
	real_torso_t = real_torso_t.rotated(Vector3(0,1,0),player_rotation)
	real_torso_t = real_torso_t.translated(head.position - head.basis.y*dist_head_neck - Vector3(0,dist_torso_neck,0))
	return real_torso_t

func real_to_torso_space(transform: Transform3D) -> Transform3D:
	var real_torso_t = get_real_torso_position()
	real_torso_t = TransformMath.to_global(real_torso_t,real_origin.global_transform)
	return TransformMath.to_global(TransformMath.to_local(transform,real_torso_t),phys_torso.global_transform)

func real_to_torso_space_local(transform: Transform3D) -> Transform3D:
	var real_torso_t = get_real_torso_position()
	#real_torso_t = TransformMath.to_global(real_torso_t,real_origin.transform)
	return TransformMath.to_global(TransformMath.to_local(transform,real_torso_t),phys_torso.global_transform)

func update_neck():
	neck_body.global_transform = real_to_torso_space(head.global_transform)
	
func update_hands():
	var desired_lhand = real_to_torso_space(left_hand.global_transform)
	var desired_rhand = real_to_torso_space(right_hand.global_transform)
	curr_desired_lhand.global_transform = desired_lhand
	curr_desired_rhand.global_transform = desired_rhand
	lhand_constraint.global_transform = phys_lhand.global_transform
	rhand_constraint.global_transform = phys_rhand.global_transform
	# woohoo reaction forces
	#phys_torso.reaction_force = reaction_force

func update_torso():
	var transform: Transform3D = Transform3D(real_origin.global_transform).rotated(real_origin.global_transform.basis.y,head.transform.basis.get_euler(EulerOrder.EULER_ORDER_YXZ).y)
	var rotation = phys_torso.global_basis.get_euler(EULER_ORDER_YXZ)
	transform = transform.rotated(Vector3.UP,rotation.y)
	transform = transform.rotated(Vector3.RIGHT,rotation.x)
	transform = transform.rotated(Vector3.BACK,rotation.z)
	desired_torso.global_transform = transform
	#phys_torso.apply_torque_impulse(-desired_torso.angular_forces)
	desired_torso.angular_forces = Vector3.ZERO

func _ready():
	standing_constraint = Generic6DOFJoint3D.new()
	add_child(standing_constraint)
	Constraints.disable_limits(standing_constraint)
	Constraints.change_strength(standing_constraint,standing_strength,standing_damping,0,0)
	Constraints.change_strength(neck_constraint,0,0,neck_strength,neck_damping)
	Constraints.change_strength(upright_constraint,0,0,upright_strength,upright_damping)
	Constraints.change_constraint_rot(neck_constraint,true)
	Constraints.change_constraint_rot(torso_rotation_constraint,false)#true)
	neck_pin.global_transform = Transform3D(phys_torso.global_transform)
	neck_pin.translate(Vector3(0,dist_torso_neck,0))
	
	
	update_strength()
	update_constraints()
	desired_standing = ForceHolder.new()
	add_child(desired_standing)
	neck_body = StaticBody3D.new()
	add_child(neck_body)
	desired_torso = ForceHolder.new()
	add_child(desired_torso)
	desired_upright = StaticBody3D.new()
	add_child(desired_upright)
	standing_constraint.global_position = phys_torso.global_position
	standing_constraint.global_rotation = phys_torso.global_rotation
	standing_constraint.node_b = phys_torso.get_path()
	standing_constraint.node_a = desired_standing.get_path()
	neck_constraint.node_b = neck_body.get_path()
	torso_rotation_constraint.node_b = desired_torso.get_path()
	upright_constraint.node_b = desired_upright.get_path()

func _physics_process(delta: float):
	update_strength()
	neck_body.constant_angular_velocity = Vector3.ZERO
	neck_body.constant_linear_velocity = Vector3.ZERO

func _process(delta: float):
	update_hands()
	update_neck()
	update_torso()
	stand(delta)
