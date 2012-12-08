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

	applyImpulse: (b2Vec) =>
		worldPosition = @body.worldBody.GetPosition()
		@body.worldBody.ApplyImpulse(b2Vec, worldPosition)



