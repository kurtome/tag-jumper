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

