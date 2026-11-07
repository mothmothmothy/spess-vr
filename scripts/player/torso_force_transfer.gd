class_name Torso extends RigidBody3D
@export var lhand: ForceHolder
@export var rhand: ForceHolder
@export var reaction_force = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if reaction_force:
		apply_impulse(lhand.forces,lhand.global_position-global_position)
		apply_impulse(rhand.forces,rhand.global_position-global_position)
		apply_torque_impulse(lhand.angular_forces)
		apply_torque_impulse(rhand.angular_forces)
	if lhand and rhand:
		lhand.forces = Vector3.ZERO
		rhand.forces = Vector3.ZERO
		lhand.angular_forces = Vector3.ZERO
		rhand.angular_forces = Vector3.ZERO
