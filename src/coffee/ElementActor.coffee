class ElementActor
	constructor: (@element, @actor) ->

	getLocation: =>
		def = {
			top: @element.scrollTop
			left: @element.scrollLeft
		}
		return def

	isVisible: =>
		if not @element.offsetWidth
			return false

		return true

	update: =>
		if this.isVisible()
			def = this.getLocation()
			@actor.setVisible(true)
			@actor.setLocation(def.left, def.top)
		else
			@actor.setVisible(false)

