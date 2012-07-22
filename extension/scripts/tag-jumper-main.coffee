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

document.body.appendChild(tjump.overlay)

# Constants
tjump.SCALE = 32.0
tjump.FRAME_RATE = 1.0 / 60
tjump.VELOCITY_ITERATIONS = 10
tjump.POSITION_ITERATIONS = 10
tjump.GRAVITY = new Box2D.Common.Math.b2Vec2(0, 0)

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


class ElementArticulator
	articulateElement: (element) =>
		if not this.isValid element
			return false

		platformDef = {
			top: element.offsetTop
			left: element.offsetLeft
			width: element.offsetWidth
		}

		tjump.createPlatform platformDef
		return true


	isValid: (element) =>
		if not element.offsetWidth
			return false

		if element.offsetWidth > tjump.canvas.offsetWidth / 3
			return false

		if element.offsetHeight > tjump.canvas.offsetHeight / 3
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
		this.parseElement document.body
		

	parseElement: (element) =>
		wasArticulated = @articulator.articulateElement element

		if wasArticulated
			return

		this.parseElement child for child in element.childNodes









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
	b2BodyDef = Box2D.Dynamics.b2BodyDef
	b2Body = Box2D.Dynamics.b2Body
	b2FixtureDef = Box2D.Dynamics.b2FixtureDef
	b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape

	fixDef = new b2FixtureDef
	fixDef.density = 1.0
	fixDef.friction = 1
	fixDef.restitution = 1

	bodyDef = new b2BodyDef
	bodyDef.type = b2Body.b2_staticBody

	fixDef.shape = new b2PolygonShape

	bodyDef.position.x = tjump.scaleToPhys (platformDef.left-(tjump.getWidth() / 2))
	bodyDef.position.y = tjump.scaleToPhys (-1 * (platformDef.top-(tjump.getHeight() / 2)))
	width = tjump.scaleToPhys(platformDef.width)
	height = tjump.scaleToPhys(5.0)
	fixDef.shape.SetAsBox(width, height)
	platform = tjump.world.CreateBody(bodyDef)
	platform.CreateFixture(fixDef)

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

	tjump.elementArticulator = new ElementArticulator()
	tjump.domParser = new DomParser(tjump.elementArticulator)

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

