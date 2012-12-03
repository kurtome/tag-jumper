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
