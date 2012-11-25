
#window = chrome.extension.getBackgroundPage()


###
 Creates a horizontal platform
###
tjump.createPlatform = (element) ->
	platformDef = {
		top: element.offsetTop
		left: element.offsetLeft
		width: element.offsetWidth
		height: element.offsetHeight
		htmlId: element.id
	}

	actor = tjump.ui.createRectActorWithBody(platformDef, tjump.world)
	body = tjump.ui.bodyFromActor actor, tjump.world

	tjump.updatables.push new ElementActor(element, actor)

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
	#tjump.world.DrawDebugData()
	tjump.world.ClearForces()
	
	updatable.update() for updatable in tjump.updatables


	# Kick off the next loop
	#requestAnimFrame(tjump.update)
# update()




###
 Initalizes everything we need to get started, should
 only be called once to set up.
###
tjump.init = ->
	tjump.updatables = []
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
	# debugDraw = new b2DebugDraw()
	# debugDraw.SetSprite(tjump.ctx)
	# debugDraw.SetDrawScale(tjump.SCALE)
	# debugDraw.SetFillAlpha(0.4)
	# debugDraw.SetLineThickness(1.0)
	# debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
	# tjump.world.SetDebugDraw(debugDraw)
# ~init() 

# Set everything up. 
tjump.init()

