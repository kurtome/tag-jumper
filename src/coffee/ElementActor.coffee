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

