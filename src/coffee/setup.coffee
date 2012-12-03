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
