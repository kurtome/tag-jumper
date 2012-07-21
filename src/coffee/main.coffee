
#window = chrome.extension.getBackgroundPage()

###
 Function that animates the 
###
window.requestAnimFrame = do -> 
	return window.requestAnimationFrame ||
		window.webkitRequestAnimationFrame ||
		window.mozRequestAnimationFrame ||
		window.oRequestAnimationFrame ||
		window.msRequestAnimationFrame ||
		(callback, element) -> 
			window.setTimeout(callback, 1000 / 60)


###
 Creates wall boundaries fo the game
###
tjump.createWalls = ->
	b2BodyDef = Box2D.Dynamics.b2BodyDef
	b2Body = Box2D.Dynamics.b2Body
	b2FixtureDef = Box2D.Dynamics.b2FixtureDef
	b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape

	fixDef = new b2FixtureDef
	fixDef.density = 1.0
	fixDef.friction = 0
	fixDef.restitution = 0.2

	bodyDef = new b2BodyDef
	bodyDef.type = b2Body.b2_staticBody

	# Create walls
	fixDef.shape = new b2PolygonShape

	# Left wall
	bodyDef.position.x = 0
	bodyDef.position.y = tjump.scaleToPhys(tjump.HEIGHT / 2)
	leftWidth = tjump.scaleToPhys(10 / 2)
	leftHeight = tjump.scaleToPhys((tjump.HEIGHT + (10 * tjump.BALL_RADIUS)) / 2)
	fixDef.shape.SetAsBox(leftWidth, leftHeight)
	tjump.leftWall = tjump.world.CreateBody(bodyDef)
	tjump.leftWall.CreateFixture(fixDef)

	# Top wall
	bodyDef.position.x = tjump.scaleToPhys(tjump.WIDTH / 2)
	bodyDef.position.y = 0
	topWidth = tjump.scaleToPhys(tjump.WIDTH / 2)
	topHeight = tjump.scaleToPhys(10 / 2)
	fixDef.shape.SetAsBox(topWidth, topHeight)
	tjump.world.CreateBody(bodyDef).CreateFixture(fixDef)

	# Right wall
	bodyDef.position.x = tjump.scaleToPhys(tjump.WIDTH)
	bodyDef.position.y = tjump.scaleToPhys(tjump.HEIGHT / 2)
	rightWidth = leftWidth
	rightHeight = leftHeight
	fixDef.shape.SetAsBox(rightWidth, leftHeight)
	tjump.world.CreateBody(bodyDef).CreateFixture(fixDef)

	# Bottom wall (off screen)
	bodyDef.position.x = tjump.scaleToPhys(tjump.WIDTH / 2)
	bodyDef.position.y = tjump.scaleToPhys(tjump.HEIGHT + (5 * tjump.BALL_RADIUS))
	bottomWidth = topWidth
	bottomHeight = topHeight
	fixDef.shape.SetAsBox(bottomWidth, topHeight)
	tjump.bottomWall = tjump.world.CreateBody(bodyDef)
	tjump.bottomWall.CreateFixture(fixDef)

	# Create two walls in the top corners to make the ball bounce off at an angle
	# (really tired of ball getting stuck)
	# Top Left
	bodyDef.position.x = tjump.scaleToPhys(1)
	bodyDef.position.y = tjump.scaleToPhys(1)
	bodyDef.angle = Math.PI / 4
	topLeftWidth = tjump.scaleToPhys(15)
	topLeftHeight = tjump.scaleToPhys(15)
	fixDef.shape.SetAsBox(topLeftWidth, topLeftHeight)
	tjump.world.CreateBody(bodyDef).CreateFixture(fixDef)
	# Top right
	bodyDef.position.x = tjump.scaleToPhys(tjump.WIDTH - 1)
	bodyDef.position.y = tjump.scaleToPhys(1)
	bodyDef.angle = Math.PI / 4
	topRightWidth = tjump.scaleToPhys(15)
	topRightHeight = tjump.scaleToPhys(15)
	fixDef.shape.SetAsBox(topRightWidth, topRightHeight)
	tjump.world.CreateBody(bodyDef).CreateFixture(fixDef)

###
 Handles the BeginContact event from the physics 
 world.
###
tjump.beginContact = (contact) ->
	tjump.paddleAi.beginContact(contact)

###
 Initalizes everything we need to get started, should
 only be called once to set up.
###
tjump.init = ->
	b2DebugDraw = Box2D.Dynamics.b2DebugDraw

	allowSleep = true
	tjump.world = new Box2D.Dynamics.b2World(tjump.GRAVITY, allowSleep)

	tjump.createWalls()

	# Contact listener for collision detection
	listener = new Box2D.Dynamics.b2ContactListener
	listener.BeginContact = tjump.beginContact
	tjump.world.SetContactListener(listener)

	# setup debug draw
	debugDraw = new b2DebugDraw()
	debugDraw.SetSprite(tjump.ctx)
	debugDraw.SetDrawScale(tjump.SCALE)
	debugDraw.SetFillAlpha(0.4)
	debugDraw.SetLineThickness(1.0)
	debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
	tjump.world.SetDebugDraw(debugDraw)
# ~init() 

###
 Does all the work we need to do at each tick of the
 game clock.
###
tjump.update = -> 
	tjump.world.Step( 
		tjump.FRAME_RATE, 
		tjump.VELOCITY_ITERATIONS, 
		tjump.POSITION_ITERATIONS 
	)
	tjump.world.DrawDebugData()
	tjump.world.ClearForces()

	# Kick off the next loop
	requestAnimFrame(tjump.update)
# update()


# Set everything up.
tjump.init()
# Begin the animation loop.
requestAnimFrame(tjump.update)

