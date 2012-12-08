# Object to namespace everything
tj = { }

# Put the overlay on

tj.overlay = document.createElement('div')
tj.overlay.id = 'main-overlay'
tj.overlay.className += 'overlay'

tj.canvas = document.createElement('canvas')
tj.canvas.id = 'main-canvas'
tj.canvas.className += 'canvas'
tj.overlay.appendChild(tj.canvas)

tj.ctx = tj.canvas.getContext("2d")

tj.$document = $(document)

document.body.appendChild(tj.overlay)

# Constants
tj.SCALE = 32.0
tj.FRAME_RATE = 1.0 / 60
tj.VELOCITY_ITERATIONS = 10
tj.POSITION_ITERATIONS = 10
tj.GRAVITY = new Box2D.Common.Math.b2Vec2(0, 10)


tj.getWidth = ->
	return tj.canvas.offsetWidth

tj.getHeight = ->
	return tj.canvas.offsetHeight

###
 Converts screen points (pixels) to points the 
 physics engine works with
###
tj.scaleToPhys = (x) -> 
	return (x / tj.SCALE)

###
 Converts screen points (pixels) vector to points 
 the physics engine works with
###
tj.scaleVecToPhys = (vec) ->
	vec.Multiply(1 / tj.SCALE)
	return vec

###
 Converts physics engine points to UI
###
tj.scaleVecFromPhys = (vec) ->
	vec.Multiply(tj.SCALE)
	return vec

###
 Converts physics points to points the screen points
 (pixels)
###
tj.scaleToScreen = (x) -> 
	return (x * tj.SCALE)


tj.createB2Vec = (x, y) ->
	vector = new Box2D.Common.Math.b2Vec2(x, y)
	return vector

tj.createB2VecScaledToPhys = (x, y) ->
	vec = tj.createB2Vec x, y
	scaledVec = tj.scaleVecToPhys vec
	return scaledVec

###
# Applies a horizontal force to a body
###
tj.applyXForce = (body, xForce) ->
	b2Vec2 = Box2D.Common.Math.b2Vec2
	centerPoint = body.GetPosition()
	force = new b2Vec2(xForce, 0)
	body.ApplyForce(force, centerPoint)

###
# Applies a vertical force to a body
###
tj.applyYForce = (body, yForce) ->
	b2Vec2 = Box2D.Common.Math.b2Vec2
	centerPoint = body.GetPosition()
	force = new b2Vec2(0, yForce)
	body.ApplyForce(force, centerPoint)

tj.isBodyInContact = (contact, body) ->
	bodyA = contact.GetFixtureA().GetBody()
	bodyB = contact.GetFixtureB().GetBody()

	if (bodyA is body or bodyB is body)
		return true
	else
		return false


class ElementWrapper
	constructor: (@element) ->
		@$element = $(element)

	getLocation: =>
		def = {
			top: @$element.offset().top - tj.$document.scrollTop(),
			left: @$element.offset().left - tj.$document.scrollLeft(),
			height: @$element.height(),
			width: @$element.width()
		}
		return def

	isVisible: =>
		return @$element.is(":visible")


class InputHandler
	keysDown: {}

	# Listen for keys being presses and being released. As this happens
	# add and remove them from the key store.
	constructor: (@player) ->
		$("body").keydown (e) => @keysDown[e.keyCode] = true
		$("body").keyup (e)   => delete @keysDown[e.keyCode]

	# Every time update is called from the game loop act on the currently
	# pressed keys by passing the events on to the world.
	update: () ->
		@player.up()    if 38 of @keysDown
		@player.down()  if 40 of @keysDown
		@player.left()  if 37 of @keysDown
		@player.right() if 39 of @keysDown



class Player
	constructor: (@bodyActor) ->

	up: =>
		vec = tj.createB2Vec(0, -2)
		@bodyActor.applyImpulse(vec)

	down: =>

	left: =>
		vec = tj.createB2Vec(1, 0)
		@bodyActor.applyImpulse(vec)

	right: =>
		vec = tj.createB2Vec(-1, 0)
		@bodyActor.applyImpulse(vec)



class BodyWrapper
	constructor: (@body) ->

	getUiPosition: =>
		worldPosition = @body.worldBody.GetPosition()
		scaledPos = tj.scaleVecFromPhys(worldPosition) 
		position = {
			x: scaledPos.x - tj.$document.scrollLeft()
			y: scaledPos.y - tj.$document.scrollTop()
		}
		return position

	applyImpulse: (b2Vec) =>
		worldPosition = @body.worldBody.GetPosition()
		@body.worldBody.ApplyImpulse(b2Vec, worldPosition)





class BodyActor
	constructor: (@bodyWrapper, @actor) ->

	update: =>
		position = @bodyWrapper.getUiPosition()
		@actor.setLocation(position.x, position.y)

	applyImpulse: (b2Vec) =>
		@bodyWrapper.applyImpulse(b2Vec)


class ElementActor
	constructor: (@elementWrapper, @actor, @body) ->

	update: =>
		def = @elementWrapper.getLocation()
		@actor.setLocation(def.left, def.top)



class GameUi
	constructor: (canvas, @world, loopCallback) ->
		width = canvas.offsetWidth
		height = canvas.offsetHeight
		@director = new CAAT.Director().initialize(width, height, canvas)
		@scene = @director.createScene()

		CAAT.PMR = tj.SCALE
		CAAT.enableBox2DDebug(true, @director, @world)

		@scene.onRenderStart = loopCallback

		#@scene.onRenderEnd = =>
			#@world.DrawDebugData()

		# Begin animating fps
		CAAT.loop tj.FRAME_RATE

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

	createPolygon : (x,y,data) ->
		body =  new CAAT.B2DPolygonBody().enableEvents(false).createBody(
			world,
					{
						x:                      x,
						y:                      y,
						bodyType:               Box2D.Dynamics.b2Body.b2_dynamicBody,
						density:                data.density,
						restitution:            data.restitution,
						friction:               data.friction,
						image:                  null,
						polygonType:            CAAT.B2DPolygonBody.Type.POLYGON,
						bodyDef:                data.polygonDef,
						bodyDefScale:           data.polygonScale,
						bodyDefScaleTolerance:  data.tolerance,
						userData:               null
					}
		);


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


		tj.createPlatform element
		return true


	isValid: (element) =>
		if not element.offsetWidth
			return false

		if element.offsetWidth > tj.canvas.offsetWidth / 2
			return false

		if element.offsetHeight > tj.canvas.offsetHeight / 2
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

