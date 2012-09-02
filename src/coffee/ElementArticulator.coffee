class ElementArticulator
	articulateElement: (element) =>
		if not this.isValid element
			return false

		if Math.random() > .5
			return false

		platformDef = {
			top: element.offsetTop
			left: element.offsetLeft
			width: element.offsetWidth
			height: 5
			htmlId: element.id
		}

		tjump.createPlatform platformDef
		return true


	isValid: (element) =>
		if not element.offsetWidth
			return false

		if element.offsetWidth > tjump.canvas.offsetWidth / 3
			return false

		if element.offsetHeight > tjump.canvas.offsetHeight / 3
			return false
		
		if element.offsetWidth < 5
			return false
		
		if element.offsetHeight < 5
			return false

		return true


