extends CharacterBody3D
#stats
var maxSpeedBase: float
var moveAccelBase: float
var airAccel: float
var jumpForce: float
var gravEffect: float
#calculatedStats
var moveAccel: float
var maxSpeed: float
var runSpeed: float

#abilitychecks
var canHighJump: bool
var canLongJump: bool
var canCrouch: bool

#miscellaneous
@onready var legs: CollisionShape3D = $groundCollision
var crouched = 1
var onFloor: bool
var momentum: Vector2
var sliding: bool
var slideTimer: float = 0 
var longJumpTimer: float = 0
var coyoteTime:float = 0
var highJumping: bool
var highJumpTimer: float = 0

func _ready() -> void:
	Globals.getStats("res://newGameStats.toml")
	updateStats()

func _physics_process(delta: float):
	if onFloor: 
		highJumpTimer -= delta
	slideTimer -= delta
	longJumpTimer -= delta
	coyoteTime -= delta
	
	onFloor = is_on_floor()
	moveAccel = moveAccelBase * crouched
	maxSpeed = maxSpeedBase * crouched
	runSpeed = min(moveAccel / 2 / crouched,maxSpeed / 2 / crouched)
	
	if not is_on_floor():
		velocity += get_gravity() * gravEffect * delta
	
	

	
	var input_dir := Input.get_vector("left", "right", "forth", "back")
	var v3direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction := Vector2(v3direction.x,v3direction.z)
	momentum = Vector2(velocity.x,velocity.z)
	
	if jumpForce > 0:
		handleJump(direction)
				
	if canCrouch:
		crouch(delta,direction)
	
	if onFloor:
		if not sliding:
			if direction:
				if abs(momentum.angle_to(direction)) >= PI/1.5:
					momentum -= momentum / 50
				elif abs(momentum.angle_to(direction)) > PI/6 and abs(momentum.angle_to(direction)) < PI/4:
					momentum = momentum.rotated(momentum.angle_to(direction)/10)
				elif abs(momentum.angle_to(direction)) >= PI/4 and abs(momentum.angle_to(direction)) <= PI/1.5:
					momentum = momentum.rotated(momentum.angle_to(direction)/50)
				var newMomentum = momentum + direction * moveAccel * delta
				if newMomentum.length_squared() < momentum.length_squared() or newMomentum.length() < runSpeed:
					newMomentum = newMomentum + direction * moveAccel * delta
				momentum = newMomentum
			else:
				if momentum.length_squared() == 0:
					pass
				elif momentum.length() > maxSpeed*delta*2:
					momentum -= momentum.normalized()*maxSpeed*delta*2
				else:
					momentum = Vector2.ZERO
			if momentum.length() > maxSpeed:
				if not sliding:
					momentum -= momentum.normalized() * (momentum.length()/maxSpeed)*0.8
		else:
			handleslide()
			momentum = (momentum + direction * moveAccel * delta).limit_length(momentum.length())
	else:
		if direction:
			airMovement(direction,delta)
	
	
	velocity.x = momentum.x
	velocity.z = momentum.y
	move_and_slide()


func airMovement(direction: Vector2, delta:float):
	var newmomentum = momentum + direction * moveAccel * airAccel * delta
	if newmomentum.length() <= maxSpeed * 1.5:
		momentum = newmomentum
	else: 
		momentum = newmomentum.limit_length(momentum.length())
	if abs(direction.angle_to(momentum)) > 0.8*PI:
		momentum = momentum / 1.1

func crouch(delta: float, direction: Vector2):
	if Input.is_action_pressed("crouch"):
		crouched = 0.5
		if legs.position.y < -0.11:
			legs.position.y += 0.1
			if onFloor:
				position.y -= 0.1
				if momentum.length() > runSpeed and not sliding and slideTimer <= 0 and abs(momentum.angle_to(direction)) < PI/4:
					sliding = true
					momentum += direction * runSpeed * 2
			else:
				if highJumpTimer <= 0 and not highJumping and canHighJump:
					highJumping = true
		elif legs.position.y > -0.1:
			legs.position.y = -0.1
	else:
		crouched = 1
		if legs.position.y > -0.6:
			legs.position.y -= 0.1
		elif legs.position.y < -0.6:
			legs.position.y = -0.6
		if highJumping:
			highJumping = false

func handleslide():
	if momentum.length() < runSpeed*1.5 or not Input.is_action_pressed("crouch") or not onFloor:
		sliding = false
	else:
		momentum -= momentum / 100
		slideTimer = 1
		
func handleJump(direction: Vector2):
	if Input.is_action_just_pressed("jump"):
		coyoteTime = 0.15
	if onFloor:
		if coyoteTime > 0:
			velocity.y += jumpForce
			momentum = (momentum + direction * runSpeed).limit_length(max(maxSpeed*1.2,momentum.length()))
			onFloor = false
			if sliding and longJumpTimer <= 0 and canLongJump:
				momentum += direction * runSpeed / crouched / 1.5
				longJumpTimer = 2
			if highJumping:
				velocity.y += jumpForce
				highJumpTimer = 0.03
			
		highJumping = false



func updateStats():
	var stats: Dictionary
	if Globals.playerStats != null:
		stats = Globals.playerStats
		print("successfully loaded stats")
	else:
		print("uh oh, there's no stats to read!")
	maxSpeedBase = stats['maxSpeed']
	moveAccelBase = stats['maxAcceleration']
	jumpForce = stats['maxJumpForce']
	airAccel = stats['airAcceleration']
	gravEffect = stats['gravity']
	canHighJump = stats['canHighJump']
	canLongJump = stats['canLongJump']
	canCrouch = stats['canCrouch']
	moveAccel = moveAccelBase
	maxSpeed = maxSpeedBase
	runSpeed = maxSpeed/2
