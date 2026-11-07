extends RigidBody3D
#func _ready():
	#print("did")
	#apply_torque_impulse(Vector3(0,0.00001,0)*mass)
#
#var t: float = 0.0
#var turns = 0
#func _process(delta: float):
	#print(angular_velocity)
	#t += delta
	#if abs(fmod(rotation_degrees.y,360)) >= 90 and t > 0:
		#turns += 1
		#print("FAAH")
		#print(angular_velocity)
		#print("blele")
		#print(t)
		#rotation_degrees = Vector3.ZERO
		#t = -100000
		
		
		
		
#func _ready():
	#apply_torque_impulse(Vector3(0.00005,0.00005,0.00005)*1*mass)
	#
#var t: float = 0.0
#var old
#var new
#func _process(delta: float):
	#if t <= 5.0 and t+delta > 5.0:
		#print("angulkar:")
		#print(angular_velocity)
		#old = angular_velocity
		#var a = (0.00416666616651)*(1.00000006208818)*(1.00000012417638)*(0.99999990065892)*(1.0000004450483)*(0.9999995549521)
		#var b = 1.0/240.0
		#TransformMath.apply_torque_impulse(self,-angular_velocity*mass*b,global_position)
	#elif t > 5.0:
		#new = angular_velocity
		#var difference = old-new
		#print("stuff:")
		#print(difference.x)
		#print(new.x)
		## old.x:abs(new.x)
		#print(old.x)
		#print(difference.x)
		#var multiplication_factor = (old.x/difference.x)
		#print(str(multiplication_factor))
	#t+=delta
func _ready():
	apply_torque_impulse(Vector3(0.00005,0.00005,0.00005)*1*mass)
	TransformMath.apply_torque_impulse(self,-angular_velocity*mass,self.global_position)
	print(angular_velocity)
