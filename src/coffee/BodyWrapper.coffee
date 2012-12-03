class BodyWrapper
	constructor: (@body) ->

	getUiPosition: =>
		worldPosition = @body.worldBody.GetPosition()
		scaledPos = tj.scaleVecFromPhys(worldPosition) 
		position = {
			x: scaledPos.x - tj.$document.scrollLeft()
			y: scaledPos.y - tj.$document.scrollTop()
		}
		return position
		#boundingBox = @body.boundingBox
		#return boundingBox[0]


