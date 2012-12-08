
#window = chrome.extension.getBackgroundPage()


###
 Creates a horizontal platform
###
tj.createPlatform = (element) ->
	elementWrapper = new ElementWrapper(element)
	platformDef = elementWrapper.getLocation()

	actor = tj.ui.createRectActorWithBody(platformDef, tj.world)
	body = tj.ui.rectBodyFromActor actor

	tj.updatables.push new ElementActor(elementWrapper, actor, body)

tj.createPlayer = ->
	platformDef = {
		top: 200
		left: 200
		width: 10
		height: 20
	}

	actor = tj.ui.createRectActorWithBody(platformDef, tj.world)
	actor.setFillStyle('green') 
	actor.setAlpha(.8)

	bodyDef = tj.ui.getDefaultBodyDef(actor)
	bodyDef.bodyType = Box2D.Dynamics.b2Body.b2_dynamicBody
	body = tj.ui.bodyFromActor actor, bodyDef

	bodyWrapper = new BodyWrapper(body)
	bodyActor = new BodyActor(bodyWrapper, actor)
	tj.updatables.push bodyActor

	player = new Player(bodyActor)


###
 Handles the BeginContact event from the physics 
 world.
###
tj.beginContact = (contact) ->
	# TODO - collission 'n stuff


###
 Does all the work we need to do at each tick of the
 game clock.
###
tj.update = -> 
	if not tj.initComplete then return

	tj.world.Step( 
		tj.FRAME_RATE, 
		tj.VELOCITY_ITERATIONS, 
		tj.POSITION_ITERATIONS 
	)
	#tj.world.DrawDebugData()
	tj.world.ClearForces()
	
	updatable.update() for updatable in tj.updatables

	tj.inputHandler.update()


	# Kick off the next loop
	#requestAnimFrame(tj.update)
# update()


###
 Initalizes everything we need to get started, should
 only be called once to set up.
###
tj.init = ->
	tj.updatables = []
	b2DebugDraw = Box2D.Dynamics.b2DebugDraw

	allowSleep = true
	tj.world = new Box2D.Dynamics.b2World(tj.GRAVITY, allowSleep)

	tj.elementArticulator = new ElementArticulator()
	tj.domParser = new DomParser(tj.elementArticulator)

	tj.ui = new GameUi(tj.canvas, tj.world, tj.update)

	# Parse the page
	tj.domParser.parsePage()

	# Contact listener for collision detection
	listener = new Box2D.Dynamics.b2ContactListener
	listener.BeginContact = tj.beginContact
	tj.world.SetContactListener(listener)

	player = tj.createPlayer()

	# Input handler
	tj.inputHandler = new InputHandler(player)

	# setup debug draw
	debugDraw = new b2DebugDraw()
	debugDraw.SetSprite(tj.ctx)
	debugDraw.SetDrawScale(tj.SCALE)
	debugDraw.SetFillAlpha(0.4)
	debugDraw.SetLineThickness(1.0)
	debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)

	tj.initComplete = true
# ~init() 

# Set everything up. 
tj.init()

