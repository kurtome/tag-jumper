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
		@elementCount = 0
		this.parseElement document.body
		

	parseElement: (element) =>
		wasArticulated = @articulator.articulateElement element
		@elementCount++

		#if wasArticulated
		#	return

		if @elementCount > 30000
			return

		this.parseElement child for child in element.childNodes






