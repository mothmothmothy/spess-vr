extends PhysicsBody3D
func on_grab(hand: RigidBody3D):
	pass
	
func get_strength() -> float:
	return 1.0

func on_release(hand: RigidBody3D):
	pass
	
func change_trigger(hand: RigidBody3D, squeeze: float):
	pass
	
func on_primary_interaction(hand: RigidBody3D, state: bool):
	pass
	
func on_secondary_interaction(hand: RigidBody3D, state: bool):
	pass
