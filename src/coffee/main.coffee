
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
 Creates a horizontal platform
###
tjump.createPlatform = (platformDef) ->
	tjump.ui.createRectActorWithBody(platformDef, tjump.world)
	#b2BodyDef = Box2D.Dynamics.b2BodyDef
	#b2Body = Box2D.Dynamics.b2Body
	#b2FixtureDef = Box2D.Dynamics.b2FixtureDef
	#b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape

	#fixDef = new b2FixtureDef
	#fixDef.density = 1.0
	#fixDef.friction = 1
	#fixDef.restitution = 1

	#bodyDef = new b2BodyDef
	#bodyDef.type = b2Body.b2_staticBody

	#fixDef.shape = new b2PolygonShape

	#bodyDef.position.x = tjump.scaleToPhys (platformDef.left-(tjump.getWidth() / 2))
	#bodyDef.position.y = tjump.scaleToPhys (-1 * (platformDef.top-(tjump.getHeight() / 2)))
	#width = tjump.scaleToPhys(platformDef.width)
	#height = tjump.scaleToPhys(5.0)
	#fixDef.shape.SetAsBox(width, height)
	#platform = tjump.world.CreateBody(bodyDef)
	#platform.CreateFixture(fixDef)

###
 Handles the BeginContact event from the physics 
 world.
###
tjump.beginContact = (contact) ->
	# TODO






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
	#requestAnimFrame(tjump.update)
# update()




###
 Initalizes everything we need to get started, should
 only be called once to set up.
###
tjump.init = ->
	b2DebugDraw = Box2D.Dynamics.b2DebugDraw

	allowSleep = true
	tjump.world = new Box2D.Dynamics.b2World(tjump.GRAVITY, allowSleep)

	tjump.elementArticulator = new ElementArticulator()
	tjump.domParser = new DomParser(tjump.elementArticulator)

	tjump.ui = new GameUi(tjump.canvas, tjump.world, tjump.update)

	# Parse the page
	tjump.domParser.parsePage()
	

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



# Set everything up.
tjump.init()
# Begin the animation loop.
requestAnimFrame(tjump.update)

