class ElementActor
	constructor: (@elementWrapper, @actor, @body) ->

	update: =>
		def = @elementWrapper.getLocation()
		@actor.setLocation(def.left, def.top)

