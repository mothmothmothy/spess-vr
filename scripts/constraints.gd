class_name ConstraintsNamespace extends Node

func change_weld(constraint: HingeJoint3D, mode: bool):
	constraint.set("angular_limit/enable",mode)

func disable_limits(constraint: Generic6DOFJoint3D):
	constraint.set("linear_limit_x/enabled",false)
	constraint.set("linear_limit_y/enabled",false)
	constraint.set("linear_limit_z/enabled",false)
	constraint.set("angular_limit_x/enabled",false)
	constraint.set("angular_limit_y/enabled",false)
	constraint.set("angular_limit_z/enabled",false)

func change_constraint(constraint: Generic6DOFJoint3D, mode: bool):
	constraint.set("angular_spring_x/enabled",mode)
	constraint.set("angular_spring_y/enabled",mode)
	constraint.set("angular_spring_z/enabled",mode)
	constraint.set("linear_spring_x/enabled",mode)
	constraint.set("linear_spring_y/enabled",mode)
	constraint.set("linear_spring_z/enabled",mode)
	
func change_constraint_rot(constraint: Generic6DOFJoint3D, mode: bool):
	constraint.set("angular_spring_x/enabled",mode)
	constraint.set("angular_spring_y/enabled",mode)
	constraint.set("angular_spring_z/enabled",mode)
	constraint.set("linear_spring_x/enabled",false)
	constraint.set("linear_spring_y/enabled",false)
	constraint.set("linear_spring_z/enabled",false)

func change_strength(constraint: Generic6DOFJoint3D, stiffness: float, damping: float, r_stiffness: float, r_damping: float):
	constraint.set("angular_spring_x/damping", r_damping)
	constraint.set("angular_spring_y/damping", r_damping)
	constraint.set("angular_spring_z/damping", r_damping)
	constraint.set("linear_spring_x/damping", damping)
	constraint.set("linear_spring_y/damping", damping)
	constraint.set("linear_spring_z/damping", damping)
	
	constraint.set("angular_spring_x/stiffness", r_stiffness)
	constraint.set("angular_spring_y/stiffness", r_stiffness)
	constraint.set("angular_spring_z/stiffness", r_stiffness)
	constraint.set("linear_spring_x/stiffness", stiffness)
	constraint.set("linear_spring_y/stiffness", stiffness)
	constraint.set("linear_spring_z/stiffness", stiffness)
	
