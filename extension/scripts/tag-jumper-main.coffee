# Object to namespace everything
tjump = { }

# Put the overlay on

tjump.overlay = document.createElement('div')
tjump.overlay.id = 'main-overlay'
tjump.overlay.className += 'overlay'

tjump.canvas = document.createElement('canvas')
tjump.canvas.id = 'main-canvas'
tjump.canvas.className += 'canvas'
tjump.overlay.appendChild(tjump.canvas)

tjump.ctx = tjump.canvas.getContext("2d")

tjump.$document = $(document)

document.body.appendChild(tjump.overlay)

# Constants
tjump.SCALE = 32.0
tjump.FRAME_RATE = 1.0 / 60
tjump.VELOCITY_ITERATIONS = 10
tjump.POSITION_ITERATIONS = 10
tjump.GRAVITY = new Box2D.Common.Math.b2Vec2(9.8, 5)

tjump.getWidth = ->
	return tjump.canvas.offsetWidth

tjump.getHeight = ->
	return tjump.canvas.offsetHeight

###
 Converts screen points (pixels) to points the 
 physics engine works with
###
tjump.scaleToPhys = (x) -> 
	return (x / tjump.SCALE)

###
 Converts screen points (pixels) vector to points 
 the physics engine works with
###
tjump.scaleVecToPhys = (vec) ->
	vec.Multiply(1 / tjump.SCALE)
	return vec

###
 Converts physics points to points the screen points
 (pixels)
###
tjump.scaleToScreen = (x) -> return (x * tjump.SCALE)

###
# Applies a horizontal force to a body
###
tjump.applyXForce = (body, xForce) ->
	b2Vec2 = Box2D.Common.Math.b2Vec2
	centerPoint = body.GetPosition()
	force = new b2Vec2(xForce, 0)
	body.ApplyForce(force, centerPoint)

###
# Applies a vertical force to a body
###
tjump.applyYForce = (body, yForce) ->
	b2Vec2 = Box2D.Common.Math.b2Vec2
	centerPoint = body.GetPosition()
	force = new b2Vec2(0, yForce)
	body.ApplyForce(force, centerPoint)

tjump.isBodyInContact = (contact, body) ->
	bodyA = contact.GetFixtureA().GetBody()
	bodyB = contact.GetFixtureB().GetBody()

	if (bodyA is body or bodyB is body)
		return true
	else
		return false


class ElementActor
	constructor: (@element, @actor) ->
		@$element = $(element)

	getLocation: =>
		def = {
			top: @$element.offset().top - tjump.$document.scrollTop()
			left: @$element.offset().left - tjump.$document.scrollLeft()
		}
		return def

	isVisible: =>
		return @$element.is(":visible")

	update: =>
		if this.isVisible()
			def = this.getLocation()
			@actor.setVisible(true)
			@actor.setLocation(def.left, def.top)
		else
			@actor.setVisible(false)



class GameUi
	constructor: (canvas, @world, loopCallback) ->
		width = canvas.offsetWidth
		height = canvas.offsetHeight
		@director = new CAAT.Director().initialize(width, height, canvas)
		@scene = @director.createScene()

		CAAT.PMR = tjump.SCALE
		CAAT.enableBox2DDebug(true, @director, @world)

		@scene.onRenderStart = loopCallback

		# Begin animating fps
		CAAT.loop tjump.FRAME_RATE

	getDefaultBodyDef : (actor) ->
		def = {
				x:                      actor.x,
				y:                      actor.y,
				bodyType:               Box2D.Dynamics.b2Body.b2_staticBody,
				density:                1,
				restitution:            1,
				friction:               1,
				image:                  null,
				polygonType:            CAAT.B2DPolygonBody.Type.BOX,
				bodyDef:                [
					{ x: actor.x,               y: actor.y },
					{ x: actor.x + actor.width, y: actor.y + actor.height }
				],
				bodyDefScale:           1,
				bodyDefScaleTolerance:  0,
				userData:               {}
			}
		return def


	bodyFromActor : (actor, bodyDef) => 
		body = CAAT.B2DPolygonBody.createPolygonBody(
			@world,
			bodyDef
		)
		return body

	rectBodyFromActor : (actor) => 
		body = CAAT.B2DPolygonBody.createPolygonBody(
			@world,
			this.getDefaultBodyDef(actor)
		)
		return body

	createRectActorWithBody: (def, @world) =>
		actor = new CAAT.Actor()
			.setLocation(def.left, def.top)
			.setSize(def.width, def.height)
			.setFillStyle('orange')
			.setAlpha(.6)

		@scene.addChild(actor)
		return actor

	createTextActor: (def) =>
		actor = new CAAT.TextActor()
			.setLocation(def.left, def.top)
			.setText(def.text)
			.setFillStyle('black')

		@scene.addChild(actor)
		return actor
		



class ElementArticulator
	articulateElement: (element) =>
		if not this.isValid element
			return false

		if Math.random() < .9
			return false


		tjump.createPlatform element
		return true


	isValid: (element) =>
		if not element.offsetWidth
			return false

		if element.offsetWidth > tjump.canvas.offsetWidth / 2
			return false

		if element.offsetHeight > tjump.canvas.offsetHeight / 2
			return false
		
		if element.offsetWidth < 5
			return false
		
		if element.offsetHeight < 5
			return false

		return true




###
# Able to parse the DOM and return a set of interesting 
# html elements for the page.
###
class DomParser
	###
	# Constructor
	###
	constructor: (@articulator) ->


	parsePage: =>
		@elementCount = 0
		this.parseElement document.body
		

	parseElement: (element) =>
		wasArticulated = @articulator.articulateElement element
		@elementCount++

		#if wasArticulated
		#	return

		if @elementCount > 30000
			return

		this.parseElement child for child in element.childNodes









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
	}

	actor = tjump.ui.createRectActorWithBody(platformDef, tjump.world)
	body = tjump.ui.rectBodyFromActor actor

	tjump.updatables.push new ElementActor(element, actor)

tjump.createPlayer = ->
	platformDef = {
		top: 200
		left: 200
		width: 10
		height: 20
	}

	actor = tjump.ui.createRectActorWithBody(platformDef, tjump.world)
	actor.setFillStyle('green') 
	actor.setAlpha(.8)

	bodyDef = tjump.ui.getDefaultBodyDef(actor)
	bodyDef.bodyType = Box2D.Dynamics.b2Body.b2_dynamicBody
	body = tjump.ui.bodyFromActor actor, bodyDef

	tjump.updatables.push new ElementActor(element, actor)


###
 Handles the BeginContact event from the physics 
 world.
###
tjump.beginContact = (contact) ->
	# TODO - collission 'n stuff




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

	tjump.createPlayer()

	setup debug draw
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

