class_name Muscle extends RigidBody3D
# move to this muscle
@export var moving_body: RigidBody3D
@export var reaction_body: RigidBody3D
@export var physics: PlayerPhysics
@export var hand: XRController3D
@export var debug_node: Node3D

@export var linear_spring_strength = 1.0
@export var linear_spring_damping = 1.0

@export var angular_spring_strength = 1.0
@export var angular_spring_damping = 10.0

var prev_diff_velocity_change: Vector3 = Vector3.ZERO

var old_transform: Transform3D
var gravity: Vector3 = Vector3.ZERO
var old_predicted_velocity: Vector3 = Vector3.ZERO
var old_predicted_angular_velocity: Vector3 = Vector3.ZERO

func apply_equal_impulse(impulse: Vector3, global_position: Vector3, state: PhysicsDirectBodyState3D):
	state.apply_impulse(impulse, global_position-moving_body.global_position)
	if reaction_body:
		reaction_body.apply_impulse(-impulse, global_position-reaction_body.global_position)

func apply_equal_angular_impulse(impulse: Vector3, global_position: Vector3, state: PhysicsDirectBodyState3D):
	TransformMath.apply_torque_impulse_state(state,impulse,global_position-moving_body.global_position)
	if reaction_body:
		TransformMath.apply_torque_impulse(reaction_body,-impulse,global_position-reaction_body.global_position)

func _ready():
	old_transform = hand.global_transform

var desired_hand_transform: Transform3D

func _process(dt: float):
	desired_hand_transform = physics.real_to_torso_space_local(hand.global_transform)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var delta = state.step
			# PIDish bit
	var new_transform = hand.global_transform
	var torso_origin_basis = physics.real_to_torso_space(Transform3D()).basis
			# spring bit
	#var desired_hand_transform = physics.real_to_torso_space_local(hand.global_transform)
	if debug_node:
		debug_node.global_transform = desired_hand_transform
	var phys_hand_transform = moving_body.global_transform
	
	# diff_velo_change
		# linear
	var position_difference = new_transform.origin-old_transform.origin
	var new_predicted_velocity = position_difference/delta
	var velocity_difference = new_predicted_velocity-old_predicted_velocity
	var linear_pid_force = velocity_difference
	var to_world = linear_pid_force.x*torso_origin_basis.x + linear_pid_force.y*torso_origin_basis.y + linear_pid_force.z*torso_origin_basis.z
	#prev_diff_velocity_change = to_world
	apply_equal_impulse(to_world*moving_body.mass,moving_body.global_position,state)
		# angular
	var angular_difference = TransformMath.to_local(new_transform,old_transform)
	var new_predicted_angular_velocity = angular_difference.basis.get_euler()/delta
	var angular_velocity_difference = new_predicted_angular_velocity-old_predicted_angular_velocity
	var angular_pid_force = angular_velocity_difference*moving_body.mass
	var to_angular_world = angular_pid_force.x*torso_origin_basis.x + angular_pid_force.y*torso_origin_basis.y + angular_pid_force.z*torso_origin_basis.z
	var rotation_multiplication_constant = (240.0/200.0)*2.0
	apply_equal_angular_impulse(to_angular_world*rotation_multiplication_constant, moving_body.global_position, state)

	
		# linear
	var to_hand_linear_force = (desired_hand_transform.origin - phys_hand_transform.origin)*moving_body.mass*delta*linear_spring_strength
	var to_hand_linear_damping = ((reaction_body.linear_velocity+prev_diff_velocity_change)-state.linear_velocity)*moving_body.mass * (1-pow((1/(1+linear_spring_damping)),delta))
	apply_equal_impulse(to_hand_linear_damping + to_hand_linear_force,phys_hand_transform.origin, state)
		# angular
	var to_hand_angular_damping = (reaction_body.angular_velocity-state.angular_velocity)*moving_body.mass * (1-pow((1/(1+angular_spring_damping)),delta))
	var to_hand_angular_force = (desired_hand_transform.basis.get_rotation_quaternion()*phys_hand_transform.basis.get_rotation_quaternion().inverse()).get_euler() * 0.1 #* angular_spring_strength * moving_body.mass
	print("be")
	print(to_hand_angular_force)
	print(to_hand_angular_damping)
	apply_equal_angular_impulse(to_hand_angular_damping+to_hand_angular_force,(state.transform*get_parent().global_transform).origin, state)
	
	
			# anti-gravity bit
	apply_equal_impulse(-gravity*delta, moving_body.global_position, state)
	
			# the rest
	old_predicted_velocity = new_predicted_velocity
	old_predicted_angular_velocity = new_predicted_angular_velocity
	old_transform = Transform3D(hand.global_transform)
	
	prev_diff_velocity_change = to_world
