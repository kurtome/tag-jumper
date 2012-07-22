class ElementArticulator
	articulateElement: (element) =>
		if not this.isValid element
			return false

		platformDef = {
			top: element.offsetTop
			left: element.offsetLeft
			width: element.offsetWidth
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


