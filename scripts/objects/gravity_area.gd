extends Area3D
func _ready():
	body_entered.connect(when_body_enters)
	body_exited.connect(when_body_leaves)

func when_body_enters(node):
	if node is Muscle:
		var muscle: Muscle = node
		muscle.gravity += gravity * gravity_direction

func when_body_leaves(node):
	if node is Muscle:
		var muscle: Muscle = node
		muscle.gravity -= gravity * gravity_direction
