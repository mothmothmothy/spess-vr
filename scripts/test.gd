extends Node
@export var a: Node3D
@export var a1: Node3D
@export var b: Node3D
@export var b1: Node3D

func _process(delta: float):
	#b1.global_transform = TransformMath.to_local(a1.global_transform,a.global_transform)
	var t = TransformMath.to_local(a1.global_transform,a.global_transform)
	b1.global_transform = TransformMath.to_global(t,b.global_transform)
