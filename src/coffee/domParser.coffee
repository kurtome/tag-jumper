###
# Able to parse the DOM and return a set of interesting 
# html elements for the page.
###
class DomParser
	###
	# Constructor
	###
	constructor: =>


	
	parseForElements:
		# TODO - this just returns mock data for our
		# test page at the moment
		elements = []

		addElement = (id) ->
			elements.push document.getElementById id

		addElement 'gameContainer'
		addElement 'notes'
		addElement 'description'
