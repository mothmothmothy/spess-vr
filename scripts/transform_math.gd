class_name TransformMathNamespace extends Node

func to_local(transform: Transform3D, space: Transform3D):
	transform = Transform3D(transform)
	space = Transform3D(space)
	
	var euler = space.basis.orthonormalized().get_euler()
	transform = transform.translated(-space.origin)
	transform = transform.rotated(Vector3.UP,-euler.y)
	transform = transform.rotated(Vector3.RIGHT,-euler.x)
	transform = transform.rotated(Vector3.BACK,-euler.z)
	
	#transform = transform * Transform3D(space.basis.orthonormalized().inverse(),-space.origin)
	return transform

func to_global(transform: Transform3D, space: Transform3D):
	return to_local(transform,space.inverse())

var multiply_factor = (1.0/2400.0)
func apply_torque_impulse(object: PhysicsBody3D, impulse: Vector3, local_position: Vector3):
	# x
	object.apply_impulse(Vector3(0,-0.5*multiply_factor*impulse.x,0),Vector3(0,0,1)+local_position)
	object.apply_impulse(Vector3(0,0.5*multiply_factor*impulse.x,0),Vector3(0,0,-1)+local_position)
	# y
	object.apply_impulse(Vector3(0,0,-0.5*multiply_factor*impulse.y),Vector3(1,0,0)+local_position)
	object.apply_impulse(Vector3(0,0,0.5*multiply_factor*impulse.y),Vector3(-1,0,0)+local_position)
	# z
	object.apply_impulse(Vector3(-0.5*multiply_factor*impulse.z,0,0),Vector3(0,1,0)+local_position)
	object.apply_impulse(Vector3(0.5*multiply_factor*impulse.z,0,0),Vector3(0,-1,0)+local_position)

func apply_torque_impulse_state(object: PhysicsDirectBodyState3D, impulse: Vector3, local_position: Vector3):
	# x
	object.apply_impulse(Vector3(0,-0.5*multiply_factor*impulse.x,0),Vector3(0,0,1)+local_position)
	object.apply_impulse(Vector3(0,0.5*multiply_factor*impulse.x,0),Vector3(0,0,-1)+local_position)
	# y
	object.apply_impulse(Vector3(0,0,-0.5*multiply_factor*impulse.y),Vector3(1,0,0)+local_position)
	object.apply_impulse(Vector3(0,0,0.5*multiply_factor*impulse.y),Vector3(-1,0,0)+local_position)
	# z
	object.apply_impulse(Vector3(-0.5*multiply_factor*impulse.z,0,0),Vector3(0,1,0)+local_position)
	object.apply_impulse(Vector3(0.5*multiply_factor*impulse.z,0,0),Vector3(0,-1,0)+local_position)
