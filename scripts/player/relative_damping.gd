class_name RelativeDamping extends Node
@export var rotational_damping: float = 0
@export var damping: float = 0
@export var node_a: RigidBody3D
@export var node_b: RigidBody3D


func _process(delta: float):
	if node_a and node_b:
		if damping > 0:
			var inverse_damping = 1/(damping+1)
			var damping_with_time = pow(inverse_damping,delta)
			
			var total_mass = node_a.mass + node_b.mass
			var desired_velocity: Vector3 = (node_a.linear_velocity*node_a.mass + node_b.linear_velocity*node_b.mass)/total_mass
			var old_velocity = node_a.linear_velocity
			var new_velocity = (node_a.linear_velocity-desired_velocity)*damping_with_time+desired_velocity
			var impulse = (new_velocity-old_velocity)*node_a.mass
			node_a.apply_impulse(impulse)
			node_b.apply_impulse(-impulse)
		if rotational_damping > 0:
			var inverse_damping = 1/(rotational_damping+1)
			var damping_with_time = pow(inverse_damping,delta)
			node_a.apply_torque_impulse(-node_a.angular_velocity*damping_with_time*node_a.mass/10)
