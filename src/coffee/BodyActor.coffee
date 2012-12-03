class BodyActor
	constructor: (@bodyWrapper, @actor) ->

	update: =>
		position = @bodyWrapper.getUiPosition()
		@actor.setLocation(position.x, position.y)
