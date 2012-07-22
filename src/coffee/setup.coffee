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
