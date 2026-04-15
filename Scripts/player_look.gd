extends Node3D

@export var body: CharacterBody3D
@export var sensitivity: float

func _ready():
	set_process_input(true)

func upDownRotation(change = 0):
	var giveBack = rotation.x + change
	
	giveBack = clamp(giveBack, PI /-2, PI/2)
	return giveBack

func leftRightRotation(change = 0):
	var giveBack = body.rotation.y + change
	return giveBack

func _input(event):
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == 2:
			#print_debug("freeing mouse")
			#print_debug("current mouse mode: " + str(Input.mouse_mode))
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			#print_debug("capturing mouse")
			#print_debug("current mouse mode: " + str(Input.mouse_mode))
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not event is InputEventMouseMotion:
		return
	
	rotation.x = upDownRotation(event.relative.y / -1000 * sensitivity)
	body.rotation.y = leftRightRotation(event.relative.x / -1000 * sensitivity)
	rotation.z = 0
	
func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _leave_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
