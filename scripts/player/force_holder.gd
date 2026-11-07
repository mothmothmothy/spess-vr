class_name ForceHolder extends RigidBody3D

var forces: Vector3 = Vector3.ZERO
var angular_forces: Vector3 = Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	forces += state.linear_velocity * self.mass
	angular_forces += state.angular_velocity * self.mass
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
