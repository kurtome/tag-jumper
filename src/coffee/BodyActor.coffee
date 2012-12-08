class BodyActor
	constructor: (@bodyWrapper, @actor) ->

	update: =>
		position = @bodyWrapper.getUiPosition()
		@actor.setLocation(position.x, position.y)

	applyImpulse: (b2Vec) =>
		@bodyWrapper.applyImpulse(b2Vec)
