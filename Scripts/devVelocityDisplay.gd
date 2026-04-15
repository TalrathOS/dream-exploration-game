extends Control

@export var xOut: Label
@export var yOut: Label
@export var zOut: Label
@export var totalout: Label
@export var watching: CharacterBody3D
var xvel
var yvel
var zvel
var veltotal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	xvel = snapped(watching.velocity.x,0.001)
	yvel = snapped(watching.velocity.y,0.001)
	zvel = snapped(watching.velocity.z,0.001)
	veltotal = snapped(Vector2(xvel,zvel).length(),0.001)
	xOut.text = str(xvel)
	yOut.text = str(yvel)
	zOut.text = str(zvel)
	totalout.text = str(veltotal)
